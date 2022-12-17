#!/usr/bin/env bash

set -euo pipefail

# @see: http://wiki.bash-hackers.org/syntax/shellvars
[ -z "${SCRIPT_DIRECTORY:-}" ] &&
    SCRIPT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

# TODO: Determine which platform automatically.

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
    "${HOMEBREW_PREFIX}/bin/brew" bundle install --file "${MACOS_DIR}/Brewfile"
    "${HOMEBREW_PREFIX}/opt/fzf/install" \
        --key-bindings \
        --completion \
        --no-update-rc
}

step_install_python() {
    local python2_version='2.7.18'
    local python3_version='3.11.1'

    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"

    eval "$(pyenv init -)"

    pyenv install "${python2_version}" || true
    pyenv install "${python3_version}" || true
    pyenv rehash
    pyenv global "${python3_version}" "${python2_version}"
}

main() {
    step_home_brew_stuff
    step_install_python
    ansible-playbook -K "${ANSIBLE_DIR}/setup-macos.yml"
    echo "Done :-)"
}

main
