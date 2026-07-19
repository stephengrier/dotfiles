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

eval "$(gds shell-completion bash)"

aws-exec() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: aws-exec <profile> <command> [args...]"
    return 1
  fi

  local profile="$1"
  shift

  (
    eval "$(aws configure export-credentials --profile "$profile" --format env)" || exit 1
    "$@"
  )
}

aws-console() {
    : "${AWS_ACCESS_KEY_ID:?AWS_ACCESS_KEY_ID not set}"
    : "${AWS_SECRET_ACCESS_KEY:?AWS_SECRET_ACCESS_KEY not set}"
    : "${AWS_SESSION_TOKEN:?AWS_SESSION_TOKEN not set}"

    local destination="${1:-https://console.aws.amazon.com/}"

    local session signin_token login_url

    session=$(
        jq -cn \
            --arg id "$AWS_ACCESS_KEY_ID" \
            --arg key "$AWS_SECRET_ACCESS_KEY" \
            --arg token "$AWS_SESSION_TOKEN" \
            '{
                sessionId: $id,
                sessionKey: $key,
                sessionToken: $token
            }'
    ) || return 1

    signin_token=$(
        curl -fsG \
            --data-urlencode "Action=getSigninToken" \
            --data-urlencode "Session=$session" \
            https://signin.aws.amazon.com/federation |
        jq -er '.SigninToken'
    ) || return 1

    login_url="https://signin.aws.amazon.com/federation?Action=login&Issuer=shell&Destination=$(printf '%s' "$destination" | jq -sRr @uri)&SigninToken=$signin_token"

    if command -v open >/dev/null 2>&1; then
        open "$login_url"          # macOS
    elif command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$login_url"      # Linux
    else
        printf '%s\n' "$login_url"
    fi
}

aws-console-dev() {
    aws-exec stephengrier-dev-admin aws-console
}

aws-console-prod() {
    aws-exec stephengrier-prod-admin aws-console
}
