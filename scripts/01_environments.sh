install_brew() {
  renew_sudo
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null
}

install_python() {
  brew install python
  # install some eggs
  pip3 install instapy-cli neovim
}

install_ruby() {
  brew install ruby
  # install some gems
  gem install --no-document neovim nokogiri pry redcarpet ronn rubocop video_transcoding watir
}

install_node() {
  brew install node
  # install some packages
  npm install --global eslint eslint-plugin-immutable eslint-plugin-shopify jsonlint neovim nightmare prettier
}
