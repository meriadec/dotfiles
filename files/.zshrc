# ============================================================================ #
#                                                                              #
# ---------                           .zshrc                           ------- #
#                                                                              #
# ============================================================================ #

# -- Init {
# =======

  ZSH=$HOME/.oh-my-zsh

# }


# -- Env {
# ======

  export EDITOR="$(which vim)"
  export GEM_HOME="~/.gem"
  export LANG=en_US.UTF-8

  export GOPATH=$HOME/dev/go

  # OSX specifics
  if [[ `uname` == 'Darwin' ]]; then

    export ANDROID_HOME=/usr/local/opt/android-sdk
    export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_74.jdk/Contents/Home

  fi

  # Linux specifics
  if [[ `uname` == 'Linux' ]]; then

    export ANDROID_HOME=/opt/android-sdk
    export CHROME_BIN='/bin/google-chrome-stable'
    export BROWSER='/bin/google-chrome-stable'

  fi

# }


# -- Commons options {
# ==================

  CASE_SENSITIVE="true"
  plugins=(git)

# }


# -- Path {
# =======

  export PATH=''

  # Android dev
  export PATH=$PATH:$ANDROID_HOME/platform-tools
  export PATH=$PATH:$ANDROID_HOME/tools

  # Go dev
  export PATH=$PATH:$GOPATH/bin

  # Commons
  export PATH=$PATH:/usr/local/sbin
  export PATH=$PATH:/usr/local/bin
  export PATH=$PATH:/usr/sbin
  export PATH=$PATH:/usr/bin
  export PATH=$PATH:/sbin
  export PATH=$PATH:/bin
  export PATH=$PATH:$HOME/bin

  # Linux specifics
  if [[ `uname` == 'Linux' ]]; then
    export PATH=$HOME/.gem/ruby/2.3.0/bin:$PATH
  fi

  # OSX specifics
  if [[ `uname` == 'Darwin' ]]; then

    export PATH=$HOME/.gem/ruby/2.0.0/bin:$PATH
    export PATH=$HOME/.brew/bin:$PATH

    export NODE_PATH=/usr/local/lib/node_modules

  fi

# }


# -- Sugar {
# ========

  source $ZSH/oh-my-zsh.sh
  source $HOME/.profile
  source $HOME/.gitprompt
  source $HOME/git/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# }
