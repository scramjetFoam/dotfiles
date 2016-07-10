install_brew() {
  renew_sudo
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null
  # disable analytics
  git config --file="$(brew --repository)/.git/config" --replace-all homebrew.analyticsdisabled true
}

install_python() {
  brew reinstall pyenv
  readonly local python_latest="$(pyenv install --list | tr -d ' ' | grep '^\d' | grep --invert-match 'dev\|a\|b' | tail -1)"
  pyenv install "${python_latest}"
  if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
  pyenv global "${python_latest}"
  # install some eggs
  # pip install ...
}

install_ruby() {
  brew reinstall chruby ruby-install
  ruby-install --src-dir "$(mktemp -d)" --latest ruby
  source '/usr/local/share/chruby/chruby.sh'
  chruby ruby
  # install some gems
  gem install --no-document bundler chromedriver2-helper ghi maid pry redcarpet rubocop seeing_is_believing site_validator video_transcoding watir-webdriver
}

install_node() {
  brew reinstall nvm
  export NVM_DIR="${HOME}/.nvm"
  source "$(brew --prefix nvm)/nvm.sh"
  nvm install node
  nvm alias default node
  # install some packages
  npm install --global eslint eslint-plugin-immutable eslint-plugin-shopify how2 jsonlint nativefier nightmare npm-check-updates pageres-cli watch webcoach
}
