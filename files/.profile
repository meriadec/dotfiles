# ============================================================================ #
#                                                                              #
# ---------                           .profile                         ------- #
#                                                                              #
# ============================================================================ #

# -- Prompt {
# =========

  export PS1=$'%{\e[0;32m%}%n%{\e[0;0m%}|%{\e[0;31m%}%m%{\e[0;33m%} %{\e[0m%}%{\e[0;37m%}%?%{\e[0m%}%{\e[0;33m%} %1~ %{\e[0m%}%{\e[0;34m%}$%{\e[0;0m%} '

# }


# -- User centred values {
# ======================

  export ZAVATTA='192.99.2.67'

# }


# -- Aliases {
# ==========

  # Let .profile manage .profile
  alias prof='vim ~/.profile && sprof'
  alias sprof='source ~/.profile'

  alias vim=nvim

  # `ls` thoughts
  alias lt='ls -lt'

  # Folders
  alias gg='cd ~/git'
  alias dl='cd ~/Downloads'
  alias dot='cd ~/git/dotfiles'
  alias gogo="cd $GOPATH/src"

  # Git
  alias gits='git status'
  alias gitp='git push'
  alias gitc='git commit'
  alias scaffold='git config --local user.name TheScaffolder && git config --local user.email spam@forpurpose.io && git commit --amend --author "TheScaffolder <spam@forpurpose.io>" && git config --local --unset user.email && git config --local --unset user.name'
  alias unscaffold='git config --local user.name meriadec && git config --local user.email meriadec.pillet@gmail.com && git commit --amend --author "meriadec <meriadec.pillet@gmail.com>" && git config --local --unset user.email && git config --local --unset user.name'

  alias sushi='google-chrome https://www.planetsushi.fr/'

  vgrep () {
    vim $(grep -rn $1 src | cut -d : -f 1 | sort | uniq)
  }

  # Linux specifics
  if [[ `uname` == 'Linux' ]]; then

    # non-retarded folder case
    alias dl='cd ~/downloads'

    # Clipboard copy
    alias pbcopy='xsel --clipboard --input'

    # Purge memory
    alias purge='sync; echo 3 | sudo tee /proc/sys/vm/drop_caches'

    # Open
    alias open=xdg-open

    say () {
       espeak -a 200 $1 2>/dev/null
    }

    download () {
      transmission-remote-cli -c $ZAVATTA $1 >/dev/null 2>/dev/null && echo 'Downloading!' || echo 'Fail.'
    }

  fi

# }


# -- Aliases {
# ==========

  source $HOME/.private

# }
