require "./terminimal/ansi"
require "./terminimal/cursor"
require "./terminimal/spinner"
require "colorize"
require "future"

# A tiny CLI toolkit for building terminal apps for humans.
module Terminimal
  extend self

  # :nodoc:
  # IO to direct all output to. Declared here so this can be overridden when
  # running specs.
  def io
    STDOUT
  end

  # Returns `Terminimal::Cursor` for interaction with the TTY cursor.
  def cursor
    Terminimal::Cursor.instance
  end

  # Create and display a `Spinner` to provide user feedback during a long
  # running operation.
  #
  # The spinner will continue to output the result of evalutation the passed
  # block while *await* returns true.
  def spinner(await : Proc(Bool), style = Spinner::Style::UNI_DOTS, async = false, &message : Proc(String)) : Nil
    spinner = Terminimal::Spinner.new await, message, style
    if async
      spawn spinner.run
    else
      spinner.run
    end
  end

  # ditto
  def spinner(await : Future::Compute, style = Spinner::Style::UNI_DOTS, async = false, &message : Proc(String))
    future_completed = ->{ await.completed? || await.canceled? }
    spinner(future_completed, style, async, &message)
  end

  # ditto
  def spinner(await : Proc(Bool), style = Spinner::Style::UNI_DOTS, async = false, message = "")
    spinner(await, style, async) { message }
  end

  # ditto
  def spinner(await : Future::Compute, style = Spinner::Style::UNI_DOTS, async = false, message = "")
    spinner(await, style, async) { message }
  end

  # Possible direction from screen and line clearing (relative to cursor pos).
  enum ClearDirection
    ToEnd   = 0
    ToStart = 1
    All     = 3
  end

  # Clears the screen and resets cursor position to 0,0.
  def clear_screen(direction = ClearDirection::All)
    io << sprintf(ANSI::CLEAR_SCREEN, direction.value)
    self
  end

  # Clears the current line in the direct specified.
  def clear_line(direction = ClearDirection::ToEnd)
    io << sprintf(ANSI::CLEAR_SCREEN, direction.value)
    self
  end

  # Clears the current line a respositions the cursor at column 0.
  def reset_line
    cursor.move_to 0
    clear_line
    self
  end

  # Prints an error message to STDERR and exits.
  def exit_with_error(message, status) : NoReturn
    abort "#{"error:".colorize.bright.red} #{message}", status
  end
end
