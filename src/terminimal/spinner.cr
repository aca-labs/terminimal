require "../terminimal"

# Utility for emitting single line user feedback to STDOUT while a long running
# process is taking place.
#
# NOTE: at the time of writing Crystal does not support parallel operations.
# When using a spinner to provide feedback during a long-running, CPU bound
# operation, you must manually invoke `Fiber.yield` to allow the fiber to be
# released and output from the spinner to be evaluated. IO bound operations
# will automatically release while awaiting resolution.
class Terminimal::Spinner
  alias CharSequence = Iterable(Char)

  # Build a type-safe set of spinner styles.
  private macro define_styles(**styles)
    # Builtin spinner styles
    enum Style
      {% for name, chars in styles %}
        # {{ chars.map { |x| "`#{x.id}`" }.join(" ").id }}
        {{ name.id.upcase }}
      {% end %}

      def character_sequence
        case self
        {% for name, chars in styles %}
        when Style::{{ name.id.upcase }} then {{ chars.map(&.chars.first) }}
        {% end %}
        # Can never happen, but required to ensure non-nil return type
        else raise ""
        end
      end
    end
  end

  define_styles(
    # ASCII based
    ascii_propeller: %w(/ - \\ |),
    ascii_plus: %w(x +),
    ascii_blink: %w(o -),
    ascii_v: %w(v < ^ >),
    ascii_inflate: %w(. o O o),

    # Uncode characters sets - these will break in non-unicode terminals
    uni_dots: %w(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏),
    uni_dots2: %w(⣾ ⣽ ⣻ ⢿ ⡿ ⣟ ⣯ ⣷),
    uni_dots3: %w(⣷ ⣯ ⣟ ⡿ ⢿ ⣻ ⣽ ⣾),
    uni_dots4: %w(⠋ ⠙ ⠚ ⠞ ⠖ ⠦ ⠴ ⠲ ⠳ ⠓),
    uni_dots5: %w(⠄ ⠆ ⠇ ⠋ ⠙ ⠸ ⠰ ⠠ ⠰ ⠸ ⠙ ⠋ ⠇ ⠆),
    uni_dots6: %w(⠋ ⠙ ⠚ ⠒ ⠂ ⠂ ⠒ ⠲ ⠴ ⠦ ⠖ ⠒ ⠐ ⠐ ⠒ ⠓ ⠋),
    uni_dots7: %w(⠁ ⠉ ⠙ ⠚ ⠒ ⠂ ⠂ ⠒ ⠲ ⠴ ⠤ ⠄ ⠄ ⠤ ⠴ ⠲ ⠒ ⠂ ⠂ ⠒ ⠚ ⠙ ⠉ ⠁),
    uni_dots8: %w(⠈ ⠉ ⠋ ⠓ ⠒ ⠐ ⠐ ⠒ ⠖ ⠦ ⠤ ⠠ ⠠ ⠤ ⠦ ⠖ ⠒ ⠐ ⠐ ⠒ ⠓ ⠋ ⠉ ⠈),
    uni_dots9: %w(⠁ ⠁ ⠉ ⠙ ⠚ ⠒ ⠂ ⠂ ⠒ ⠲ ⠴ ⠤ ⠄ ⠄ ⠤ ⠠ ⠠ ⠤ ⠦ ⠖ ⠒ ⠐ ⠐ ⠒ ⠓ ⠋ ⠉ ⠈ ⠈),
    uni_dots10: %w(⢹ ⢺ ⢼ ⣸ ⣇ ⡧ ⡗ ⡏),
    uni_dots11: %w(⢄ ⢂ ⢁ ⡁ ⡈ ⡐ ⡠),
    uni_dots12: %w(⠁ ⠂ ⠄ ⡀ ⢀ ⠠ ⠐ ⠈),
    uni_bounce: %w(⠁ ⠂ ⠄ ⠂),
    uni_pipes: %w(┤ ┘ ┴ └ ├ ┌ ┬ ┐),
    uni_hands: %w(☜ ☝ ☞ ☟),
    uni_arrow_rot: %w(➫ ➭ ➬ ➭),
    uni_triangle: %w(◢ ◣ ◤ ◥),
    uni_square: %w(◰ ◳ ◲ ◱),
    uni_box_bounce: %w(▖ ▘ ▝ ▗),
    uni_pie: %w(◴ ◷ ◶ ◵),
    uni_circle: %w(◐ ◓ ◑ ◒),
    uni_qtr_circle: %w(◜ ◝ ◞ ◟)
  )

  UPDATE_INTERVAL = 0.15 # seconds (~30fps)

  # Creates a new spinner instance.
  #
  # Spinners will continue to run until *await* returns true. During operation
  # they will continue to output the result of evaluting *message* to STDOUT,
  # clearing the line, and overwriting itself on each update.
  #
  # The style of the spinning can be of the builtin `Style` options, or
  # alternatively any custom `CharSequence`.
  def initialize(@await, @message, style : Style | CharSequence = Style::UNI_DOTS)
    @character_sequence = style.is_a?(Style) ? style.character_sequence.as(CharSequence) : style
  end

  # :nodoc:
  # IO to direct all output to. Declared here so this can be overridden when
  # running specs.
  def io
    Terminimal.io
  end

  private getter await : Proc(Bool)
  private getter message : Proc(String)
  private getter character_sequence : CharSequence

  # Start spinning.
  def run
    animation = character_sequence.cycle.each
    until await.call
      io << "#{animation.next} #{message.call}"
      sleep UPDATE_INTERVAL
      Terminimal.reset_line
    end
  end
end
