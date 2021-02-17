# Change macOS configurations with no manual intervention required
function configure_macos_auto {
  renew_sudo

  info 'Expand save panel by default.'
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

  info 'Save to disk (not to iCloud) by default.'
  defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

  info 'Disable Resume system-wide.'
  defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

  info 'Enable full keyboard access for all controls.'
  # (e.g. enable Tab in modal dialogs)
  defaults write NSGlobalDomain AppleKeyboardUIMode -int 2

  info 'Disable auto-correct.'
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

  info 'Set Home as the default location for new Finder windows.'
  defaults write com.apple.finder NewWindowTarget -string 'PfLo'
  defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

  info 'Show all filename extensions in Finder.'
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true

  info 'Remove items from the Trash after 30 days.'
  defaults write com.apple.finder FXRemoveOldTrashItems -bool true

  info 'Disable the warning when changing a file extension.'
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

  info 'Show item information near icons on the desktop.'
  /usr/libexec/PlistBuddy -c 'Set :DesktopViewSettings:IconViewSettings:showItemInfo true' "${HOME}/Library/Preferences/com.apple.finder.plist"

  info 'Increase grid spacing for icons on the desktop.'
  /usr/libexec/PlistBuddy -c 'Set :DesktopViewSettings:IconViewSettings:gridSpacing 100' "${HOME}/Library/Preferences/com.apple.finder.plist"

  info 'Increase the size of icons on the desktop.'
  /usr/libexec/PlistBuddy -c 'Set :DesktopViewSettings:IconViewSettings:iconSize 128' "${HOME}/Library/Preferences/com.apple.finder.plist"

  info 'Use columns view in all Finder windows by default.'
  # Four-letter codes for the other view modes: 'icnv', 'Nlsv', 'Flwv'
  defaults write com.apple.finder FXPreferredViewStyle -string 'clmv'

  info 'In ~, show the Library directory and hide others.'
  chflags nohidden "${HOME}/Library"
  chflags hidden "${HOME}/Applications"
  chflags hidden "${HOME}/Documents"
  chflags hidden "${HOME}/Music"
  chflags hidden "${HOME}/Pictures"
  chflags hidden "${HOME}/Public"

  info 'Allow scroll gesture with ⌃ to zoom.'
  defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
  defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144
  # Follow the keyboard focus while zoomed in
  defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true

  info 'Set hot corners.'
  # Possible values:
  #  0: no-op
  #  2: Mission Control
  #  3: Show application windows
  #  4: Desktop
  #  5: Start screen saver
  #  6: Disable screen saver
  #  7: Dashboard
  # 10: Put display to sleep
  # 11: Launchpad
  # Top right screen corner → Notification Center
  defaults write com.apple.dock wvous-tr-corner -int 12

  info 'Make Dock icons of hidden applications translucent'
  defaults write com.apple.dock showhidden -bool true

  info 'Do not show recent applications in Dock'
  defaults write com.apple.dock show-recents -bool false

  info 'Disable Time Machine.'
  sudo tmutil disable

  info 'Use Cloudflare and APNIC DNS servers.'
  sudo networksetup -setdnsservers Wi-Fi 1.1.1.1 1.0.0.1

  info 'Applying options.'
  for app in 'Dock' 'Finder'; do
    killall "${app}" &> /dev/null
  done

  info 'Set dark menu bar and Dock.'
  osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true'

  info 'Set Dock size and screen edge.'
  osascript -e 'tell application "System Events" to tell dock preferences to set properties to {dock size:0.3, screen edge:left}'
}

# Change macOS configurations that require manual intervention
# Find values for System Preferences by opening the desired pane and running the following AppleScript:
# tell application "System Preferences" to return anchors of current pane
function configure_macos_manual {
  ask_gui 'Allow to send and receive SMS messages.' 'Messages'

  ask_system_preferences 'Always prefer tabs when opening documents.' 'com.apple.preference.dock'
  ask_system_preferences 'Turn off showing mirroring options in the menu bar.' 'com.apple.preference.displays'
  ask_system_preferences 'Turn on Night Shift' 'com.apple.preference.displays' 'displaysNightShiftTab'
  ask_system_preferences 'Turn off Spotlight keyboard shortcut.' 'com.apple.preference.keyboard' 'shortcutsTab'
  ask_system_preferences 'Download other languages.' 'com.apple.preference.keyboard' 'Dictation'
  ask_system_preferences 'ALL TABS: Set Trackpad preferences.' 'com.apple.preference.trackpad'
  ask_system_preferences 'Uncheck what you do not want synced to iCloud.' 'com.apple.preferences.icloud'
  ask_system_preferences 'Remove Game Center.' 'com.apple.preferences.internetaccounts'
  ask_system_preferences 'Turn off Guest User account.' 'com.apple.preferences.users'
  ask_system_preferences 'Download and keep only "Ava" and "Joana" voices.' 'com.apple.preference.universalaccess' 'TextToSpeech'
  ask_system_preferences 'Under "Trackpad Options…", enable three finger drag.' 'com.apple.preference.universalaccess' 'Mouse'
}

function set_lock_screen_message {
  local email telephone
  renew_sudo

  ask 'Give contact information to be set in the lock screen:'
  read -rp 'Email address: ' email
  read -rp 'Telephone number: ' telephone
  sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText -string "$(echo -e "If found, please contact:\nEmail: ${email}\nTel: ${telephone}")"
}

function lower_startup_chime {
  renew_sudo
  info 'Ensuring a low volume of the startup chime.'

  curl -fsSLo '/tmp/lowchime' 'https://raw.githubusercontent.com/vitorgalvao/lowchime/master/lowchime'
  chmod +x '/tmp/lowchime'
  sudo /tmp/lowchime install
}

function install_commercial_fonts {
  local -r tmp_fonts_dir="$(mktemp -d)"
  info 'Installing commercial fonts.'

  for font_zip in "${HOME}/Library/Mobile Documents/com~apple~CloudDocs/Fonts/"*; do
    ditto -xk "${font_zip}" "${tmp_fonts_dir}"
  done

  find "${tmp_fonts_dir}" -iname '*otf' -exec mv '{}' "${HOME}/Library/Fonts" \;
}

function install_launch_agents {
  renew_sudo
  info 'Setting up launch daemons and agents.'

  local -r plists_dir="${1}"
  local -r user_launchagents_dir="${HOME}/Library/LaunchAgents"
  local -r global_launchdaemons_dir='/Library/LaunchDaemons/'
  [[ -d "${user_launchagents_dir}" ]] || mkdir -p "${user_launchagents_dir}"

  cp "${plists_dir}/user_plists"/* "${user_launchagents_dir}"
  chmod 644 "${user_launchagents_dir}"/*
  launchctl bootstrap "gui/$(id -u "${USER}")" "${user_launchagents_dir}"

  sudo cp "${plists_dir}/global_plists"/* "${global_launchdaemons_dir}"
  sudo chmod 644 "${global_launchdaemons_dir}"/*
  sudo chown root "${global_launchdaemons_dir}"/*
  sudo launchctl bootstrap 'system' "${global_launchdaemons_dir}"
}
