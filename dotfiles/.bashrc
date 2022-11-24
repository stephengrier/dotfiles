# ~/.bashrc: executed by bash(1) for non-login shells.

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

if [ -d $HOME/.rbenv ]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
fi

# https://gist.github.com/trey/2722934
source /opt/homebrew/etc/profile.d/bash_completion.sh
GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWCOLORHINTS=true

# Set a shell prompt.
pcolour_cyan='\[\033[36m\]'
pcolour_yellow='\[\033[33m\]'
pcolour_reset='\[\033[00m\]'
PROMPT_COMMAND="__git_ps1 '${pcolour_cyan}\u@\h${pcolour_reset}: ${pcolour_yellow}\w${pcolour_reset}' '\n→ '"

# Configure gpg-agent.
GPG_TTY=$(tty)
export GPG_TTY
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent
# Make sure pinentry knows what terminal to display on.
gpg-connect-agent updatestartuptty /bye > /dev/null 2>&1

PATH=$PATH:~/git/gds-cli/bin

export GOPATH=$HOME/go:$HOME/git/personal/golang

eval "$(/opt/homebrew/bin/brew shellenv)"
