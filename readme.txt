bash_functions and bash_go are files which should be added to the end of the .profile file

Example:

...
# set PATH so it includes user's private bin directories
PATH="$HOME/bin:$HOME/.local/bin:$PATH"
source ~/.bash_go
source ~/.bash_locals
