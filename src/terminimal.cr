require "./terminimal/ansi"
require "./terminimal/cursor"
require "colorize"

# A tiny CLI toolkit for building terminal apps for humans.
module Terminimal
  extend self

  protected class_getter io : IO = STDOUT

  # Returns `Terminimal::Cursor` for interaction with the TTY cursor.
  def cursor
    Terminimal::Cursor.instance
  end

  # Possible direction from screen and line clearing (relative to cursor pos).
  enum ClearDirection
    ToEnd = 0
    ToStart = 1
    All = 3
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

  # Prints to STDERR and exits
  def exit_with_error(message, exit_code) : NoReturn
    STDERR.puts "#{"error:".colorize.bright.red} #{message}"
    exit exit_code
  end
end
