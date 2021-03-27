function install_brew_apps {
  info 'Installing Homebrew packages.'
  brew install aria2 cpulimit duti exiftool ffmpeg gifski git handbrake hr imagemagick jq kepubify mas massren media-info megatools mkvtoolnix mp4v2 neovim ripgrep rmlint shellcheck trash tree youtube-dl z
  brew install --HEAD mpv

  info 'Installing Homebrew ZSH plugins.'
  brew install zsh-autosuggestions zsh-history-substring-search zsh-syntax-highlighting

  info 'Installing from Homebrew third-party taps.'
  brew install smudge/smudge/nightlight

  brew tap vitorgalvao/tiny-scripts
  brew install alfred-add-requested alfred-placeholder-workflows alfred-rebuild-notificator alfred-rebuild-helpers alfred-workflow-update alfred-workflows-renamer app-icon-extract calm-notifications cask-analytics cli-approve-button cli-merge-button gfv human-media-time labelcolor lossless-compress makeicns mtg-wallpapers pedir-gas pinboard-backup pinboard-link-check pinboard-url-update pinboard-waybackmachine pkg-extract progressbar ringtonemaker rtp-download seren trello-purge-archives upload-file
}

function install_cask_apps {
  renew_sudo
  info 'Installing casks.'

  brew install --cask 1password alfred bartender bettertouchtool dropbox epic-games gitup google-chrome iterm2 keka phoenix processing protonvpn safari-technology-preview shotcut steam terminology transmission vmware-fusion yacreader

  renew_sudo
  info 'Installing cask versions.'
  brew tap homebrew/cask-versions
  brew install --cask screenflow5

  renew_sudo
  info 'Installing drivers.'
  # Nothing here

  info 'Installing prefpanes, qlplugins, colorpickers'
  # Nothing here

  info 'Installing fonts.'
  brew tap homebrew/cask-fonts
  # Subtitles, recommended in https://www.md-subs.com/saa-subtitle-font
  brew install --cask font-clear-sans
  # Multiple
  brew install --cask font-alegreya font-alegreya-sans
  brew install --cask font-fira-mono font-fira-sans
  brew install --cask font-merriweather font-merriweather-sans
  brew install --cask font-pt-mono font-pt-sans font-pt-serif
  brew install --cask font-source-code-pro font-source-sans-pro font-source-serif
  # Sans
  brew install --cask font-aileron font-cozette font-exo2 font-montserrat font-lato font-open-sans font-open-sans-condensed font-signika
  # Serif
  brew install --cask font-abril-fatface font-gentium-book-basic font-playfair-display font-playfair-display-sc
  # Slab
  brew install --cask font-bitter font-kreon
}

function install_mas_apps {
  info 'Installing Mac App Store apps.'

  local -r mas_apps=('1password=443987910' 'affinity-designer=824171161' 'affinity-photo=824183456' 'boop=1518425043' 'clear=504544917' 'dropshelf=540404405' 'glance=1513574319' 'haskell=841285201' 'ia-writer=775737590' 'quiver=866773894' 'reeder=880001334' 'spark=1176895641' 'trello=1278508951' 'tweetbot=1384080005' 'tyme=1063996724' 'wipr=1320666476' 'xcode=497799835')

  local app_id

  for app in "${mas_apps[@]}"; do
    app_id="${app#*=}"
    mas install "${app_id}"
  done
}
