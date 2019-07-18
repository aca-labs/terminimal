require "./terminimal/ansi"
require "./terminimal/cursor"
require "./terminimal/spinner"
require "colorize"

# A tiny CLI toolkit for building terminal apps for humans.
module Terminimal
  extend self

  # :nodoc:
  def io
    STDOUT
  end

  # Returns `Terminimal::Cursor` for interaction with the TTY cursor.
  def cursor
    Terminimal::Cursor.instance
  end

  def spinner(await : Proc(Bool), style = Spinner::Style::UNI_DOTS, async = false, &message : Proc(String)) : Nil
    spinner = Terminimal::Spinner.new await, message, style
    if async
      spinner.run
    else
      spawn spinner.run
    end
  end

  def spinner(await : Concurrent::Future, style = Spinner::Style::UNI_DOTS, async = false, &message : Proc(String))
    future_completed = -> { await.completed? || await.canceled? }
    spinner future_completed, style, async, &message
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
  def abort(message, status) : NoReturn
    abort "#{"error:".colorize.bright.red} #{message}", status
  end
end
