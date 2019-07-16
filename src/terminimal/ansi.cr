# ANSI control sequences.
module Terminimal::ANSI
  CURSOR_UP        = "\e[A"
  CURSOR_DOWN      = "\e[B"
  CURSOR_FORWARD   = "\e[C"
  CURSOR_BACK      = "\e[D"
  CURSOR_NEXT_LINE = "\e[E"
  CURSOR_PREV_LINE = "\e[F"

  CURSOR_HORIZONTAL_ABS = "\e[%dG"

  CURSOR_MOVE = "\e[%d;%dH"

  CURSOR_POS_SAVE    = "\e[s"
  CURSOR_POS_RESTORE = "\e[u"

  CURSOR_SHOW = "\e[?25h"
  CURSOR_HIDE = "\e[?25l"

  CLEAR_SCREEN = "\e[%dJ"
  CLEAR_LINE   = "\e[%dK"
end
