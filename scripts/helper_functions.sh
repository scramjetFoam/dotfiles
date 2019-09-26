function message {
  local bullet_color="${1}"
  local message="${2}"
  local all_colors=('black' 'red' 'green' 'yellow' 'blue' 'magenta' 'cyan' 'white')

  for i in "${!all_colors[@]}"; do
    if [[ "${all_colors[${i}]}" == "${bullet_color}" ]]; then
      local color_index="${i}"
      echo -e "$(tput setaf "${i}")•$(tput sgr0) ${message}"
      break
    fi
  done

  if [[ -z "${color_index}" ]]; then
    echo "${FUNCNAME[0]}: '${bullet_color}' is not a valid color."
    return 1
  fi
}

# Ask for info to be given in the Terminal
function ask {
  (afplay /System/Library/Sounds/Hero.aiff &) # Run in subshell so we do not see job information; send to the background so it does not hold up execution while playing
  message 'magenta' "${1}"
}

# Ask for a manual GUI action to be done
function ask_gui {
  local message="${1}"
  local app="${2}"
  shift 2

  ask "${message}"
  open -Wa "${app}" --args "${@}" # Do not continue until app closes
}

# Open `System Preferences` in specified pane
function ask_system_preferences {
  local message="${1}"
  local pane="${2}"
  local tab="${3}" # Optionally specify a tab in the pane

  if [[ -z "${tab}" ]]; then
    osascript -e "tell application \"System Preferences\" to reveal pane \"${pane}\"" 1>/dev/null
  else
    osascript -e "tell application \"System Preferences\" to reveal anchor \"${tab}\" of pane \"${pane}\"" 1>/dev/null
  fi

  ask_gui "${1}" 'System Preferences'
}

function ask_chromium {
  local chromium_app="${1}"
  local extension_name="${2}"
  local extension_code="${3}"

  ask_gui "Install '${extension_name}' extension." "${chromium_app}" --no-first-run "https://chrome.google.com/webstore/detail/${extension_code}"
}

# General info of something to happen
function info {
  message 'green' "${1}"
}

function renew_sudo {
  if ! sudo --non-interactive true 2> /dev/null; then
    ask 'Extend `sudo` timeout by giving your password now (will not be echoed).'
  fi

  sudo --validate
}
