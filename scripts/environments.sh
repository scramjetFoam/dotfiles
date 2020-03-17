function install_brew {
  renew_sudo
  info 'Installing Homebrew.'

  if command -v brew; then
    echo 'It was already done.'
    return 0
  fi

  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null
}

function install_python {
  info 'Installing Python and eggs.'

  rm -rf "${HOME}/.pyenv" # Get rid of previous install, if any
  brew install pyenv

  pyenv install "$(pyenv install --list | sed 's/^  //' | grep '^\d' | grep --invert-match 'dev\|a\|b' | tail -1)" # Install latest stable python
  pyenv global "$(pyenv versions | tail -1 | sed 's/^[\* ]*//;s/ .*//')" # Switch to latest installed python
  eval "$(pyenv init -)" # Activate pyenv

  # Install some eggs
  pip install neovim
}

function install_ruby {
  info 'Installing Ruby and gems.'

  rm -rf "${HOME}"/.{gem,rubies} # Get rid of previous install, if any
  brew install chruby ruby-install

  ruby-install --src-dir "$(mktemp -d)" ruby # Install latest stable ruby
  source '/usr/local/opt/chruby/share/chruby/chruby.sh' # Activate chruby
  chruby ruby # Switch to latest installed ruby

  # Install some gems
  gem install --no-document neovim nokogiri ronn rubocop video_transcoding watir
}

function install_node {
  info 'Installing Node and packages.'

  rm -rf "${HOME}/.nvm" # Get rid of previous install, if any
  brew install nvm

  # Activate nvm
  mkdir "${HOME}/.nvm"
  export NVM_DIR="${HOME}/.nvm"
  [ -s '/usr/local/opt/nvm/nvm.sh' ] && source '/usr/local/opt/nvm/nvm.sh'

  nvm install node # Install latest node

  # Install some packages
  npm install --global neovim
}
