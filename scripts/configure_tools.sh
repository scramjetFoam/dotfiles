#!/bin/bash
function restore_settings {
  info 'Restoring app settings.'
  ruby "${HOME}/Library/Mobile Documents/com~apple~CloudDocs/Tape/tape" restore
}

function set_keyboard_shortcuts {
  info 'Setting custom keyboard shortcuts.'
  # Custom keyboard shortcuts for apps
  # @ is ⌘; ~ is ⌥; $ is ⇧; ^ is ⌃
  # Read more at https://web.archive.org/web/20140810142907/http://hints.macworld.com/article.php?story=20131123074223584

  # Global
  # defaults write -g NSUserKeyEquivalents '{}'

  # Contacts
  defaults write com.apple.AddressBook NSUerKeyEquivalents '{
    "Edit Card"="@E";
  }'

  # ScreenFlow 5
  defaults write net.telestream.screenflow5 NSUserKeyEquivalents '{
    "Add Screen Recording Action"="~r";
    "Split Clip"="s";
  }'
}

function set_default_apps {
  info 'Setting default apps.'

  # Make Spotlight aware of mpv
  if [[ -z "$(mdfind kMDItemCFBundleIdentifier = 'io.mpv')" ]]; then
    mdimport -i "$(find "$(brew --prefix)" -type d -name 'mpv.app' | tail -1)"
  fi

  # General extensions
  for ext in {aac,avi,f4v,flac,m4a,m4b,mkv,mov,mp3,mp4,mpeg,mpg,part,wav,webm}; do duti -s io.mpv "${ext}" all; done # Media
  for ext in {7z,bz2,gz,rar,tar,tgz,zip}; do duti -s com.aone.keka "${ext}" all; done # Archives
  for ext in {cbr,cbz}; do duti -s com.richie.YACReader "${ext}" all; done # Image archives
  for ext in {md,txt}; do duti -s pro.writer.mac "${ext}" all; done # Text
  for ext in {css,js,json,php,pug,py,rb,sh}; do duti -s com.microsoft.VSCode "${ext}" all; done # Code

  # Affinity apps (use beta versions when possible)
  # Whenever a stable is more recent than the beta, the beta cannot be used, so we need to detect which is latest and always use that
  local afd_id='com.seriflabs.affinitydesigner'
  local afp_id='com.seriflabs.affinityphoto'
  local afdbeta_id='com.seriflabs.affinitydesigner.beta'
  local afpbeta_id='com.seriflabs.affinityphoto.beta'

  local afd_location="$(mdfind kMDItemCFBundleIdentifier = "${afd_id}")"
  local afp_location="$(mdfind kMDItemCFBundleIdentifier = "${afp_id}")"
  local afdbeta_location="$(mdfind kMDItemCFBundleIdentifier = "${afdbeta_id}")"
  local afpbeta_location="$(mdfind kMDItemCFBundleIdentifier = "${afpbeta_id}")"

  local afd_version="$(mdls -raw -name kMDItemVersion "${afd_location}")"
  local afp_version="$(mdls -raw -name kMDItemVersion "${afp_location}")"
  local afdbeta_version="$(mdls -raw -name kMDItemVersion "${afdbeta_location}" | sed -E 's/ \(.*//')"
  local afpbeta_version="$(mdls -raw -name kMDItemVersion "${afpbeta_location}" | sed -E 's/ \(.*//')"

  [[ "${afd_version}" == "${afdbeta_version}" ]] && local afd_latest="${afd_id}" || local afd_latest="${afdbeta_id}"
  [[ "${afp_version}" == "${afpbeta_version}" ]] && local afp_latest="${afp_id}" || local afp_latest="${afpbeta_id}"

  for ext in {afdesign,eps}; do duti -s "${afd_latest}" "${ext}" all; done
  for ext in {afphoto,psd}; do duti -s "${afp_latest}" "${ext}" all; done
}

function configure_git {
  local full_name github_email github_username github_password github_token
  ask 'Give details to configure git:'
  read -rp 'First and last names: ' full_name
  read -rp 'GitHub email: ' github_email
  read -rp 'GitHub username: ' github_username
  read -rsp "GitHub password (never stored): " github_password
  echo

  git config --global user.name "${full_name}"
  git config --global github.user "${github_username}"
  git config --global user.email "${github_email}"
  git config --global credential.helper osxkeychain

  ask 'Request a GitHub token for CLI use.'
  local request=(curl --silent 'https://api.github.com/authorizations' --user "${github_username}:${github_password}" --data "{\"scopes\":[\"repo\"],\"note\":\"macOS CLI for ${USER} on $(scutil --get LocalHostName)\"}")

  local response="$("${request[@]}")"

  while grep --quiet 'Must specify two-factor authentication OTP code.' <<< "${response}"; do
    read -rp '2FA code: ' otp
    response="$("${request[@]}" --header "X-GitHub-OTP: ${otp}")"
  done

  if ! grep --quiet '"token"' <<< "${response}"; then
    echo -e "\n${response}" >&2
    return
  fi

  local github_token="$(grep 'token' <<< "${response}" | head -1 | cut -d'"' -f4)"

  info 'Storing GitHub token in Keychain.'
  git credential-osxkeychain store <<< "$(echo -e "host=github.com\nprotocol=https\nusername=${github_username}\npassword=${github_token}")"

  ask 'Request a GitHub token for `climergebutton`.'
  climergebutton --ensure-token
}

function install_editor_packages {
  info 'Installing Neovim packages.'
  curl --silent --location 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' --output "${HOME}/.local/share/nvim/site/autoload/plug.vim" --create-dirs
  nvim +PlugInstall +qall > /dev/null

  info 'Skipping atom packages for now.'

  info 'Installing VSCode packages.'
  code --install-extension dbaeumer.vscode-eslint gerane.Theme-Peacock misogi.ruby-rubocop timonwong.shellcheck vscodevim.vim
}

function configure_pinboard_scripts {
  local pinboard_token
  ask 'Give Pinboard token for configuration of personal Pinboard scripts:'
  read -rp 'Pinboard token: ' pinboard_token

  pinboardlinkcheck --save-token --token "${pinboard_token}"
}

function install_chromium_extensions {
  ask_chromium 'Google Chrome' '1Password extension' 'aomjjhallfgjeglblehebfpbcfeobpgk'
  ask_chromium 'Google Chrome' 'uBlock Origin' 'cjpalhdlnbpafiamejdnhcphjbkeiagm'
  ask_chromium 'Google Chrome' 'Unsplash Instant' 'pejkokffkapolfffcgbmdmhdelanoaih'

  ask_gui 'Remove Google-imposed extensions.' 'Google Chrome'
}
