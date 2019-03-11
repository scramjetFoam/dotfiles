#!/bin/bash

# helper functions
info() {
  echo "$(tput setaf 2)•$(tput sgr0) ${1}"
}

request() { # output a message and open an app
  local message="${1}"
  local app="${2}"
  shift 2

  echo "$(tput setaf 5)•$(tput sgr0) ${message}"
  open -Wa "${app}" --args "${@}" # don't continue until app closes
}

request_preferences() { # 'request' for System Preferences
  request "${1}" 'System Preferences'
}

request_chromium_extension() { # 'request' for Google Chrome extensions
  local chromium_app="${1}"
  local extension_short_name="${2}"
  local extension_code="${3}"

  request "Install '${extension_short_name}' extension." "${chromium_app}" --no-first-run "https://chrome.google.com/webstore/detail/${extension_short_name}/${extension_code}"
}

preferences_pane() { # open 'System Preferences' is specified pane
  osascript -e "tell application \"System Preferences\"
    reveal pane \"${1}\"
    activate
  end tell" &> /dev/null
}

preferences_pane_anchor() { # open 'System Preferences' is specified pane and tab
  osascript -e "tell application \"System Preferences\"
    reveal anchor \"${1}\" of pane \"${2}\"
    activate
  end tell" &> /dev/null
}

# intial message
clear

echo "This script will help configure the rest of macOS. It is divided in two parts:

  $(tput setaf 2)•$(tput sgr0) Commands that will change settings without needing intervetion.
  $(tput setaf 5)•$(tput sgr0) Commands that will require manual interaction.

  The first part will simply output what it is doing (the action itself, not the commands).

  The second part will open the appropriate panels/apps, inform what needs to be done, and pause. Unless prefixed with the message 'ALL TABS', all changes can be performed in the opened tab.
  After the changes are done, close the app and the script will continue.
" | sed -E 's/ {2}//'

# ask for 'sudo' authentication
if sudo --non-interactive true 2> /dev/null; then
  read -s -n0 -p "$(tput bold)Some commands require 'sudo', but it seems you have already authenticated. When you’re ready to continue, press ↵.$(tput sgr0)"
  echo
else
  echo -n "$(tput bold)When you’re ready to continue, insert your password. This is done upfront for the commands that require 'sudo'.$(tput sgr0) "
  sudo --validate
fi

# first part
# more options on http://mths.be/macos

info 'Expand save panel by default.'
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

info 'Save to disk (not to iCloud) by default.'
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

info 'Disable Resume system-wide.'
defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

info 'Enable full keyboard access for all controls.'
# (e.g. enable Tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

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

info 'Show item info near icons on the desktop.'
/usr/libexec/PlistBuddy -c 'Set :DesktopViewSettings:IconViewSettings:showItemInfo true' "${HOME}/Library/Preferences/com.apple.finder.plist"

info 'Increase grid spacing for icons on the desktop.'
/usr/libexec/PlistBuddy -c 'Set :DesktopViewSettings:IconViewSettings:gridSpacing 100' "${HOME}/Library/Preferences/com.apple.finder.plist"

info 'Increase the size of icons on the desktop.'
/usr/libexec/PlistBuddy -c 'Set :DesktopViewSettings:IconViewSettings:iconSize 128' "${HOME}/Library/Preferences/com.apple.finder.plist"

info 'Use columns view in all Finder windows by default.'
# Four-letter codes for the other view modes: 'icnv', 'Nlsv', 'Flwv'
defaults write com.apple.finder FXPreferredViewStyle -string 'clmv'

info 'Show the ~/Library folder, and hide Applications, Documents, Music, Pictures and Public.'
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
# Bottom left screen corner → Desktop
defaults write com.apple.dock wvous-bl-corner -int 4
# Top right screen corner → Notification Center
defaults write com.apple.dock wvous-tr-corner -int 12
# Bottom right screen corner → Mission Control
defaults write com.apple.dock wvous-br-corner -int 2

info 'Disable Time Machine.'
sudo tmutil disable

info 'Use Cloudflare and APNIC DNS servers.'
sudo networksetup -setdnsservers Wi-Fi 1.1.1.1 1.0.0.1

for app in 'Dock' 'Finder'; do
  killall "${app}" &> /dev/null
done

info 'Set dark menu bar and Dock.'
osascript -e 'tell application "System Events" to tell appearance preferences to set properties to {dark mode:true}'

info 'Set Dock size and screen edge.'
osascript -e 'tell application "System Events" to tell dock preferences to set properties to {dock size:0.17, screen edge:left}'

# second part
# find values for System Preferences by opening the desired pane and running the following AppleScript:
# tell application "System Preferences" to return anchors of current pane

echo

request 'Allow to send and receive SMS messages.' 'Messages'

preferences_pane 'com.apple.preference.dock'
request_preferences 'Always prefer tabs when opening documents.'

preferences_pane 'com.apple.preference.displays'
request_preferences 'Turn off showing mirroring options in the menu bar.'

preferences_pane_anchor 'shortcutsTab' 'com.apple.preference.keyboard'
request_preferences "Turn off Spotlight's keyboard shortcut."

preferences_pane_anchor 'Dictation' 'com.apple.preference.keyboard'
request_preferences 'Download other languages.'

preferences_pane 'com.apple.preference.trackpad'
request_preferences 'ALL TABS: Set Trackpad preferences.'

preferences_pane 'com.apple.preferences.icloud'
request_preferences "Uncheck what you don't want synced to iCloud."

preferences_pane 'com.apple.preferences.internetaccounts'
request_preferences 'Remove Game Center.'

preferences_pane 'com.apple.preferences.users'
request_preferences 'Turn off Guest User account.'

preferences_pane 'com.apple.preference.speech'
request_preferences 'Set Siri voice.'

preferences_pane_anchor 'TextToSpeech' 'com.apple.preference.universalaccess'
request_preferences 'Download and keep only "Ava" and "Joana" voices.'

preferences_pane_anchor 'Mouse' 'com.apple.preference.universalaccess'
request_preferences 'Under "Trackpad Options…", enable three finger drag.'

# chromium extentions

echo

request_chromium_extension 'Google Chrome' '1password-password-manage' 'aomjjhallfgjeglblehebfpbcfeobpgk'
request_chromium_extension 'Google Chrome' 'httpseverywhere' 'gcbommkclmclpchllfjekcdonpmejbdp'
request_chromium_extension 'Google Chrome' 'ublockorigin' 'cjpalhdlnbpafiamejdnhcphjbkeiagm'
request_chromium_extension 'Google Chrome' 'unsplash-instant' 'pejkokffkapolfffcgbmdmhdelanoaih'

request 'Remove Google-imposed extensions.' 'Google Chrome'

# misc

echo

request 'Create a token with the "repo" scope for CLI access.' 'Google Chrome' 'https://github.com/settings/tokens'
read -p 'Github username: ' github_username
read -p 'Github token: ' github_token
echo "host=github.com
protocol=https
password=${github_token}
username=${github_username}" | git credential-osxkeychain store
