restore_settings() {
  ruby "${HOME}/Library/Mobile Documents/com~apple~CloudDocs/darkhouse/_run_house/quick_restore.rb"
}

set_default_apps() {
  # open the mpv app bundle, so the system actually sees it (since it's not in a standard location)
  readonly local mpv_location="$(readlink "$(brew --prefix)/bin/mpv" | sed "s:^\.\.:$(brew --prefix):;s:bin/mpv$:mpv.app:")"
  if [[ -n "${mpv_location}" ]]; then
    readonly local mpv_process="$(pgrep -f 'mpv.app')"
    if [[ -z "${mpv_process}" ]]; then
      open "${mpv_location}"
      sleep 2
      killall mpv
    fi
  fi

  # general extensions
  for ext in {aac,avi,f4v,flac,m4a,m4b,mkv,mov,mp3,mp4,mpeg,mpg,part,wav,webm}; do duti -s io.mpv "${ext}" all; done # media
  for ext in {7z,bz2,gz,rar,tar,tgz,zip}; do duti -s com.aone.keka "${ext}" all; done # archives
  for ext in {cbr,cbz}; do duti -s com.richie.YACReader "${ext}" all; done # image archives
  for ext in {css,js,json,md,php,pug,py,rb,sh,txt}; do duti -s com.github.atom "${ext}" all; done # code

  # Affinity apps (use beta versions when possible)
  # Whenever a beta is older than the stable, the beta cannot be used, so we need to detect which is latest and always use that
  readonly local afd_id='com.seriflabs.affinitydesigner'
  readonly local afp_id='com.seriflabs.affinityphoto'
  readonly local afdbeta_id='com.seriflabs.affinitydesigner.beta'
  readonly local afpbeta_id='com.seriflabs.affinityphoto.beta'

  readonly local afd_location="$(mdfind kMDItemCFBundleIdentifier = "${afd_id}")"
  readonly local afp_location="$(mdfind kMDItemCFBundleIdentifier = "${afp_id}")"
  readonly local afdbeta_location="$(mdfind kMDItemCFBundleIdentifier = "${afdbeta_id}")"
  readonly local afpbeta_location="$(mdfind kMDItemCFBundleIdentifier = "${afpbeta_id}")"

  readonly local afd_version="$(mdls -raw -name kMDItemVersion "${afd_location}")"
  readonly local afp_version="$(mdls -raw -name kMDItemVersion "${afp_location}")"
  readonly local afdbeta_version="$(mdls -raw -name kMDItemVersion "${afdbeta_location}" | sed -E 's/ \(.*//')"
  readonly local afpbeta_version="$(mdls -raw -name kMDItemVersion "${afpbeta_location}" | sed -E 's/ \(.*//')"

  [[ "${afd_version}" == "${afdbeta_version}" ]] && readonly local afd_latest="${afd_id}" || readonly local afd_latest="${afdbeta_id}"
  [[ "${afp_version}" == "${afpbeta_version}" ]] && readonly local afp_latest="${afp_id}" || readonly local afp_latest="${afpbeta_id}"

  for ext in {afdesign,eps}; do duti -s "${afd_latest}" "${ext}" all; done
  duti -s "${afp_latest}" afphoto all
}

set_keyboard_shortcuts() {
  # Custom keyboard shortcuts for apps
  # @ is ⌘; ~ is ⌥; $ is ⇧; ^ is ⌃
  # read more at https://web.archive.org/web/20140810142907/http://hints.macworld.com/article.php?story=20131123074223584

  # Global
  # defaults write -g NSUserKeyEquivalents '{}'

  # ScreenFlow 5
  defaults write net.telestream.screenflow5 NSUserKeyEquivalents '{
    "Add Screen Recording Action"="~r";
    "Split Clip"="s";
  }'
}

install_commercial_fonts() {
  readonly local tmp_fonts_dir="$(mktemp -d)"

  for font_zip in "${HOME}/Library/Mobile Documents/com~apple~CloudDocs/fonts/"*; do
    ditto -xk "${font_zip}" "${tmp_fonts_dir}"
  done

  find "${tmp_fonts_dir}" -iname '*otf' -exec mv '{}' "${HOME}/Library/Fonts" \;
}

configure_zsh() { # make zsh default shell
  sudo --stdin sh -c 'echo "/usr/local/bin/zsh" >> /etc/shells' <<< "${sudo_password}" 2> /dev/null
  sudo --stdin chsh -s '/usr/local/bin/zsh' "${USER}" <<< "${sudo_password}" 2> /dev/null
}

install_nvim_packages() {
  curl --silent --location 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' --output "${HOME}/.config/nvim/autoload/plug.vim" --create-dirs
  nvim +PlugInstall +qall > /dev/null
}

install_atom_packages() {
  apm install highlight-line language-haskell language-pug language-swift linter linter-eslint linter-jsonlint linter-rubocop linter-shellcheck linter-write-good relative-numbers vim-mode-plus vim-mode-plus-keymaps-for-surround
}

configure_git() {
  git config --global user.name "${name}"
  git config --global user.email "${github_email}"
  git config --global github.user "${github_username}"
  git config --global credential.helper osxkeychain
  git config --global push.default simple
  git config --global rerere.enabled true
  git config --global rerere.autoupdate true
}

configure_massren() {
  massren --config editor 'nvim'
  massren --config include_header 0
}

configure_pinboard_scripts() {
  pinboardlinkcheck --save-token --token "${pinboard_token}"
}

install_launchagents() {
  readonly local user_launchagents_dir="${HOME}/Library/LaunchAgents"
  readonly local global_launchdaemons_dir='/Library/LaunchDaemons/'
  mkdir -p "${user_launchagents_dir}"

  for plist_file in "${helper_files}/launchd_plists/user_plists"/*; do
    local plist_name="$(basename "${plist_file}")"

    mv "${plist_file}" "${user_launchagents_dir}"
    chmod 644 "${user_launchagents_dir}/${plist_name}"
    launchctl load -w "${user_launchagents_dir}/${plist_name}"
  done

  for plist_file in "${helper_files}/launchd_plists/global_plists"/*; do
    local plist_name="$(basename "${plist_file}")"

    sudo mv "${plist_file}" "${global_launchdaemons_dir}" <<< "${sudo_password}" 2> /dev/null
    sudo chmod 644 "${global_launchdaemons_dir}/${plist_name}"
    sudo chown root "${global_launchdaemons_dir}/${plist_name}" <<< "${sudo_password}" 2> /dev/null
    sudo launchctl load -w "${global_launchdaemons_dir}/${plist_name}" <<< "${sudo_password}" 2> /dev/null
  done

  rmdir -p "${helper_files}/launchd_plists"/* 2> /dev/null
}

lower_startup_chime() {
  curl -fsSL 'https://raw.githubusercontent.com/vitorgalvao/lowchime/master/lowchime' --output '/tmp/lowchime'
  chmod +x '/tmp/lowchime'
  sudo --stdin /tmp/lowchime install <<< "${sudo_password}" 2> /dev/null
}
