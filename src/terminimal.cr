require "./terminimal/ansi"
require "./terminimal/cursor"
require "colorize"

# A tiny CLI toolkit for building terminal apps for humans.
module Terminimal
  extend self

  # Returns `Terminimal::Cursor` for interaction with the TTY cursor.
  def cursor
    Terminimal::Cursor.instance
  end

  # Clears the current line of STDOUT up to *max_chars*.
  def clear_line(max_chars = 80)
    print "\e[#{max_chars}D"
  end

  # Prints to STDERR and exits
  def exit_with_error(message, exit_code) : NoReturn
    STDERR.puts "#{"error:".colorize.bright.red} #{message}"
    exit exit_code
  end
end
