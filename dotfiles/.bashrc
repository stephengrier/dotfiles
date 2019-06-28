# ~/.bashrc: executed by bash(1) for non-login shells.

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

if [ -d $HOME/.rbenv ]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
fi

# Enable SSH shell completions.
export ANSIBLE_DIR=$HOME/git/verify-ansible
source "${ANSIBLE_DIR}/shell_completions"

# https://gist.github.com/trey/2722934
source /usr/local/etc/bash_completion.d/git-prompt.sh
source /usr/local/etc/bash_completion.d/git-completion.bash
GIT_PS1_SHOWDIRTYSTATE=true

# Set a shell prompt.
hostname=$(hostname -s)
PS1='[\u@${hostname} \w$(__git_ps1)]\$ '

# Configure gpg-agent.
GPG_TTY=$(tty)
export GPG_TTY
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent
# Make sure pinentry knows what terminal to display on.
gpg-connect-agent updatestartuptty /bye > /dev/null 2>&1

PATH=$PATH:~/git/gds-cli/bin
