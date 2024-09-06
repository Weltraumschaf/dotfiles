#!/usr/bin/env bash

set -euo pipefail

# Python versions we use w/ Pyenv:
PYTHON3_VERSION='3.12.4'
# Ruby version we use w/ rbenv:
RUBY_VERSION="3.3.2"

# @see: http://wiki.bash-hackers.org/syntax/shellvars
[ -z "${SCRIPT_DIRECTORY:-}" ] &&
    SCRIPT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

USAGE="$(basename "${0}") <HOST_NAME> <DOMAIN_NAME>"
HOST_NAME="${1:-}"

if [[ -z "${HOST_NAME}" ]]; then
    >&2 echo "No host name given as first argument!"
    >&2 echo "${USAGE}"
    exit 1
fi

DOMAIN_NAME="${2:-}"

if [[ -z "${DOMAIN_NAME}" ]]; then
    >&2 echo "No domain name given as second argument!"
    >&2 echo "${USAGE}"
    exit 1
fi

PROCESSOR_ARCH=$(uname -p)
HOMEBREW_PREFIX=''

if [[ "${PROCESSOR_ARCH}" == 'i386' ]]; then
    # Pre Silicon Homebrew installs into /usr/local.
    HOMEBREW_PREFIX=/usr/local
elif [[ "${PROCESSOR_ARCH}" == 'arm' ]]; then
    # Since Silicon Homebrew installs into /usr/local.
    HOMEBREW_PREFIX="/opt/homebrew"
else
    >&2 echo "Unsupported processor architecture: ${PROCESSOR_ARCH}"
    exit 1
fi

PROJECT_DIR="$(dirname "${SCRIPT_DIRECTORY}")"
SRC_DIR="${PROJECT_DIR}/src"
MACOS_DIR="${SRC_DIR}/macos"
ANSIBLE_DIR="${SRC_DIR}/ansible"

step_system_settings_stuff() {
    sudo scutil --set ComputerName "${HOST_NAME}"
    sudo scutil --set HostName "${HOST_NAME}.${DOMAIN_NAME}"
    sudo scutil --set LocalHostName "${HOST_NAME}"

    sudo systemsetup -settimezone "Europe/Berlin"
    sudo systemsetup -setnetworktimeserver "ptbtime1.ptb.de"

    # Require password immediately after sleep or screen saver begins.
    sudo defaults write com.apple.screensaver askForPassword -int 1
    sudo defaults write com.apple.screensaver askForPasswordDelay -int 0
    # Save screenshots to the pictures dir.
    sudo defaults write com.apple.screencapture location -string "${HOME}/Pictures/Screenshots/"
    # Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF).
    sudo defaults write com.apple.screencapture type -string "png"

    # Disable game center. Who uses that thing?
    sudo launchctl unload -w /System/Library/LaunchAgents/com.apple.gamed.plist 2> /dev/null

    # Enable automatic software updates.
    sudo softwareupdate --schedule on
}

step_home_brew_stuff() {
    echo "Setup home brew stuff..."

    if [ -x "${HOMEBREW_PREFIX}/bin/brew" ]; then
        echo "Homebrew already installed!"
        # Since the env is not reloaded brew is not in the path yet.
        "${HOMEBREW_PREFIX}/bin/brew" update
        "${HOMEBREW_PREFIX}/bin/brew" update
        "${HOMEBREW_PREFIX}/bin/brew" upgrade
        "${HOMEBREW_PREFIX}/bin/brew" upgrade --cask
        "${HOMEBREW_PREFIX}/bin/brew" cleanup
    else
        echo "Install Homebrew..."
        (curl -sSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash)
    fi

    echo "Install basics with homebrew..."
    # https://thoughtbot.com/blog/brewfile-a-gemfile-but-for-homebrew
    # Write the Brewfile: brew bundle dump --describe --force --verbose --file "${PROJECT}/src/macos/Brewfile"
    set +e
    "${HOMEBREW_PREFIX}/bin/brew" bundle install --file "${MACOS_DIR}/Brewfile"
    set -e
    "${HOMEBREW_PREFIX}/opt/fzf/install" \
        --key-bindings \
        --completion \
        --no-update-rc
}

step_install_python() {
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"

    eval "$(pyenv init -)"

    pyenv install "${PYTHON3_VERSION}" || true
    pyenv rehash
    pyenv global "${PYTHON3_VERSION}" 
}

step_install_ruby() {
    # see https://medium.com/@jules2689/homebrew-ruby-and-gems-78d6c26b89e
    # List available versions: rbenv install --list
    eval "$(rbenv init -)"
    rbenv install -f "${RUBY_VERSION}"
    rbenv rehash
    rbenv global "${RUBY_VERSION}"
}

step_install_nvm() {
    # https://github.com/nvm-sh/nvm#installing-and-updating
    (curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash)
}

step_ansible_playbook() {
    ansible-playbook -K "${ANSIBLE_DIR}/setup-macos.yml"
}

main() {
    step_system_settings_stuff
    step_home_brew_stuff
    step_install_python
    step_install_ruby
    step_install_nvm
    step_ansible_playbook
    echo "Done :-)"
}

main
