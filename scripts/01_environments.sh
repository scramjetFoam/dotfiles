function install_brew {
  renew_sudo
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null
}

function install_python {
  brew install pyenv

  pyenv install "$(pyenv install --list | sed 's/^  //' | grep '^\d' | grep --invert-match 'dev\|a\|b' | tail -1)" # install latest stable python
  pyenv global $(pyenv versions | tail -1) # switch to latest installed python
  eval "$(pyenv init -)" # activate pyenv

  # Install some eggs
  pip install instapy-cli neovim subliminal
}

function install_ruby {
  brew install chruby ruby-install

  ruby-install --src-dir "$(mktemp -d)" ruby # install latest stable ruby
  source /usr/local/opt/chruby/share/chruby/chruby.sh # activate chruby
  chruby ruby # switch to latest installed ruby

  # Install some gems
  gem install --no-document neovim nokogiri pry redcarpet ronn rubocop video_transcoding watir
}

function install_node {
  brew install nvm

  # activate nvm
  mkdir "${HOME}/.nvm"
  export NVM_DIR="${HOME}/.nvm"
  [ -s '/usr/local/opt/nvm/nvm.sh' ] && source '/usr/local/opt/nvm/nvm.sh'

  nvm install node # install latest node

  # install some packages
  npm install --global eslint eslint-plugin-immutable eslint-plugin-shopify jsonlint neovim nightmare prettier
}
