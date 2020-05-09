function install_brew_apps {
  info 'Installing Homebrew packages.'
  brew install aria2 cpulimit duti exiftool ffmpeg geckodriver gifski git handbrake haskell-stack hr imagemagick jq kepubify mas massren media-info megatools mkvtoolnix mp4v2 neovim pup ripgrep rmlint shellcheck source-highlight sox svgcleaner trash tree youtube-dl z

  info 'Installing Homebrew ZSH plugins.'
  brew install zsh-autosuggestions zsh-completions zsh-history-substring-search zsh-syntax-highlighting

  info 'Installing from Homebrew third-party taps.'
  brew tap vitorgalvao/tiny-scripts
  brew install alfred-add-requested alfred-placeholder-workflows alfred-rebuild-notificator alfred-rebuild-sharedresources alfred-workflow-update alfred-workflows-renamer app-icon-extract cask-analytics cask-repair climergebutton contagem-edp gfv human-media-time labelcolor lossless-compress lovecolor macspoof makeicns mtg-wallpapers pedir-gas pinboardbackup pinboardlinkcheck pinboardurlupdate pinboardwaybackmachine pkg-extract podbook progressbar ringtonemaker rtp-download seren trello-purge-archives upload-file
  brew install --HEAD vitorgalvao/mpv/mpv
}

function install_cask_apps {
  renew_sudo
  info 'Installing casks.'

  brew cask install alfred apple-events atom bartender bettertouchtool dolphin dropbox firefox fog gitup google-chrome imageoptim imitone iterm2 keka phoenix processing protonvpn safari-technology-preview shotcut steam terminology transmission visual-studio-code vmware-fusion wwdc yacreader

  renew_sudo
  info 'Installing cask versions.'
  brew tap homebrew/cask-versions
  brew cask install affinity-designer-beta affinity-photo-beta screenflow5

  renew_sudo
  info 'Installing drivers.'
  brew tap homebrew/cask-drivers
  brew cask install xbox360-controller-driver-unofficial

  info 'Installing prefpanes, qlplugins, colorpickers'
  brew cask install epubquicklook qlcolorcode qlimagesize qlmarkdown qlstephen quicklook-json quicklookase

  info 'Installing fonts.'
  brew tap homebrew/cask-fonts
  # Multiple
  brew cask install font-alegreya font-alegreya-sans
  brew cask install font-fira-mono font-fira-sans
  brew cask install font-merriweather font-merriweather-sans
  brew cask install font-pt-mono font-pt-sans font-pt-serif
  brew cask install font-source-code-pro font-source-sans-pro font-source-serif-pro
  # Sans
  brew cask install font-aileron font-exo2 font-montserrat font-lato font-open-sans font-open-sans-condensed font-signika
  # Serif
  brew cask install font-abril-fatface font-gentium-book-basic font-playfair-display font-playfair-display-sc
  # Slab
  brew cask install font-bitter font-kreon
}

function install_mas_apps {
  info 'Installing Mac App Store apps.'

  local mas_apps=('1password=443987910' 'affinity-designer=824171161' 'affinity-photo=824183456' 'clear=504544917' 'dropshelf=540404405' 'haskell=841285201' 'ia-writer=775737590' 'quiver=866773894' 'reeder=880001334' 'spark=1176895641' 'trello=1278508951' 'tweetbot=557168941' 'tyme=1063996724' 'wipr=1320666476' 'xcode=497799835')

  for app in "${mas_apps[@]}"; do
    local app_id="${app#*=}"
    mas install "${app_id}"
  done
}
