# exports
# locale

set -xU LC_CTYPE en_US.UTF-8
set -xU LC_ALL en_US.UTF-8

set -xU TERM xterm-color
set -xU CLICOLOR 1

set -xU HOMEBREW_CASK_OPTS "--appdir=/Applications"

# set path vars
# Python 3
#set -gx PATH $PATH "/Library/Frameworks/Python.framework/Versions/3.4/bin"
# GNU core utilities
set -gx PATH $PATH (brew --prefix coreutils)/libexec/gnubin:/usr/local/bin


# init autojump
[ -f /usr/local/share/autojump/autojump.fish ];