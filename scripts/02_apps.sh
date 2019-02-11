install_brew_apps() {
  brew install aria2 cpulimit duti ffmpeg geckodriver gifski git handbrake haskell-stack hr httpie imagemagick jq mas massren mediainfo megatools mkvtoolnix mp4v2 mpv neovim pup ripgrep rmlint shellcheck sox svgcleaner trash tree youtube-dl z zsh

  # install zsh_plugins
  brew install zsh-autosuggestions zsh-completions zsh-history-substring-search zsh-syntax-highlighting

  # install software from other taps
  brew install vitorgalvao/kepubify/kepubify
}

install_cask_apps() {
  renew_sudo # to make the Caskroom on first install
  brew cask install alfred apple-events atom bartender bettertouchtool blockblock dolphin dropbox electron-api-demos firefox fog gifloopcoder gitup imageoptim imitone iterm2 keka lulu phoenix processing shotcut steam transmission whatsyoursign wwdc yacreader

  # install alternative versions
  brew tap homebrew/cask-versions
  brew cask install affinity-designer-beta affinity-photo-beta screenflow5

  # drivers
  brew tap homebrew/cask-drivers
  renew_sudo
  brew cask install xbox360-controller-driver-unofficial

  # prefpanes, qlplugins, colorpickers
  brew cask install betterzipql epubquicklook qlcolorcode qlmarkdown qlplayground qlstephen quicklook-json quicklookase

  # fonts
  brew tap homebrew/cask-fonts
  # multiple
  brew cask install font-alegreya font-alegreya-sans font-alegreya-sans-sc font-alegreya-sc
  brew cask install font-fira-mono font-fira-sans
  brew cask install font-input
  brew cask install font-merriweather font-merriweather-sans
  brew cask install font-pt-mono font-pt-sans font-pt-serif
  brew cask install font-source-code-pro font-source-sans-pro font-source-serif-pro
  # sans
  brew cask install font-aileron font-bebas-neue font-exo2 font-inter-ui font-montserrat font-lato font-open-sans font-open-sans-condensed font-signika
  # serif
  brew cask install font-abril-fatface font-butler font-gentium-book-basic font-playfair-display font-playfair-display-sc
  # slab
  brew cask install font-bitter font-kreon
  # script
  brew cask install font-pecita
}

install_tinyscripts() {
  brew tap vitorgalvao/tiny-scripts
  brew install annotmd cask-repair climergebutton contagem-edp gfv human-media-time labelcolor lovecolor macspoof pedir-gas pinboardbackup pinboardlinkcheck pinboardurlupdate pinboardwaybackmachine podbook progressbar ringtonemaker seren trello-purge-archives workflows-renamer
}

install_mas_apps() {
  readonly local mas_apps=('1password=443987910' 'affinity-designer=824171161' 'affinity-photo=824183456' 'colorsnapper2=969418666' 'dropshelf=540404405' 'haskell=841285201' 'ia-writer=775737590' 'quiver=866773894' 'reeder=880001334' 'spark=1176895641' 'trello=1278508951' 'tweetbot=557168941' 'xcode=497799835')

  mas signin "${mas_email}" "${mas_password}"

  for app in "${mas_apps[@]}"; do
    local app_id="${app#*=}"
    mas install "${app_id}"
  done
}
