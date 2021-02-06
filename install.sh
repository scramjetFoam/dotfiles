#!/bin/bash

export PATH="/opt/homebrew/bin:/usr/local/bin:${PATH}"
caffeinate & # Prevent computer from going to sleep

tmp_dir="$(mktemp -d)"
curl --location 'https://github.com/vitorgalvao/dotfiles/archive/master.zip' | ditto -xk - "${tmp_dir}"

for shell_script in "${tmp_dir}/dotfiles-master/scripts/"*.sh; do
  source "${shell_script}"
done

function show_options {
  clear

  echo "
    What do you want to do next?

    [1] Update the system.
    [2] Configure macOS.
    [3] Setup language environments.
    [4] Install apps.
    [5] Configure tools.
    [0] Quit.
  " | sed -E 's/ {4}//'

  read -n1 -rp 'Pick a number: ' option
  clear

  if [[ "${option}" -eq 1 ]]; then
    sync_icloud
    mas_login
    update_system
  elif [[ "${option}" -eq 2 ]]; then
    configure_macos_auto
    configure_macos_manual
    set_lock_screen_message
    lower_startup_chime
    install_commercial_fonts
    install_launch_agents "${tmp_dir}/dotfiles-master/files/launchd_plists"
  elif [[ "${option}" -eq 3 ]]; then
    install_brew
    install_python
    install_ruby
    install_node
  elif [[ "${option}" -eq 4 ]]; then
    install_brew_apps
    install_cask_apps
    install_mas_apps
  elif [[ "${option}" -eq 5 ]]; then
    restore_settings
    set_keyboard_shortcuts
    set_default_apps
    configure_git
    install_editor_packages
    configure_pinboard_scripts
    install_chromium_extensions
    install_alfred_workflow_launch_agents
  elif [[ "${option}" -eq 0 ]]; then
    # Let computer go to sleep again
    killall 'caffeinate'

    sudo --remove-timestamp

    return 0
  else
    echo 'Not a valid option. Try again.' >&2
  fi

  show_options
}

renew_sudo
show_options
