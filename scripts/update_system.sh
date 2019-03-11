function sync_icloud {
  ask 'Press the download icons to download everything.'
  open "${HOME}/Library/Mobile Documents/com~apple~CloudDocs"
  read -n0 -rp 'Press ↵ to continue.'
}

function mas_login {
  ask_gui 'Login to the App Store.' 'App Store'
}

function update_system {
  softwareupdate --install --all
}
