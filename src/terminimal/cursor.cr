require "../terminimal"
require "./ansi"

class Terminimal::Cursor
  def self.instance : self
    @@instance ||= new
  end

  private def initialize
    @hidden = false
  end

  # :nodoc:
  # IO to direct all output to. Declared here so this can be overridden when
  # running specs.
  def io
    Terminimal.io
  end

  # Hides the cursor until instructed to re-display it with `#show` or the
  # application exits.
  def hide
    hide!
    at_exit { show }
    Signal::INT.trap do
      show
      exit 125
    end
  end

  # Hides the current cursor position.
  #
  # Using the method directly is not recommended, however if you do, it is
  # important to ensure you call `#show` prior to exiting.
  def hide!
    io << ANSI::CURSOR_HIDE
    @hidden = true
    self
  end

  # Show the cursor.
  def show
    io << ANSI::CURSOR_SHOW
    @hidden = false
    self
  end

  # Get the last known cursor visibility.
  def hidden?
    @hidden
  end

  # Move the cursor position *cells* spots in *direction*.
  def move(direction, cells = 1)
    code = case direction
           when :up
             ANSI::CURSOR_UP
           when :down
             ANSI::CURSOR_DOWN
           when :forward, :right
             ANSI::CURSOR_FORWARD
           when :back, :backward, :left
             ANSI::CURSOR_BACK
           when :next_line, :line_down
             ANSI::CURSOR_NEXT_LINE
           when :prev_line, :line_up
             ANSI::CURSOR_PREV_LINE
           else
             raise "Unsupported direction: #{direction}"
           end

    if cells > 1
      code = "\e[#{cells}#{code[-1]}"
    elsif cells < 1
      raise "cells must be positive"
    end

    io << code
    self
  end

  # Position the cursor at the specific line/column position.
  def move_to(line : Int, column : Int)
    raise "coordinates must be non-negative" if line < 0 || column < 0
    io << sprintf(ANSI::CURSOR_MOVE, line, column)
    self
  end

  # Position the cursor at the specific column on the current line.
  def move_to(column : Int)
    raise "column must be non-negative" if column < 0
    io << sprintf(ANSI::CURSOR_HORIZONTAL_ABS, column)
    self
  end

  # Saves the current cursor position for later recall via `#restore_position`.
  def save_position
    io << ANSI::CURSOR_POS_SAVE
    self
  end

  # Restores the previously save cursor position.
  def restore_position
    io << ANSI::CURSOR_POS_RESTORE
    self
  end
end
