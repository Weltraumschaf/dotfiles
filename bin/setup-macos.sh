#!/usr/bin/env bash

set -euo pipefail

# @see: http://wiki.bash-hackers.org/syntax/shellvars
[ -z "${SCRIPT_DIRECTORY:-}" ] \
    && SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

PROJECT_DIR="$(dirname "${SCRIPT_DIRECTORY}")"
SRC_DIR="${PROJECT_DIR}/src"
MACOS_DIR="${SRC_DIR}/macos"
ANSIBLE_DIR="${SRC_DIR}/ansible"

step_home_brew_stuff() {
    echo "Setup home brew stuff..."

    if [ -x /usr/local/bin/brew ] ; then
        echo "Homebrew already installed!"
        brew update && brew update && brew upgrade && brew upgrade --cask && brew cleanup
    else
        echo "Install homebrew..."
        (curl -sSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash)
    fi

    echo "Install basics with homebrew..."
    # https://thoughtbot.com/blog/brewfile-a-gemfile-but-for-homebrew
    # Write the Brewfile: brew bundle dump --describe --force --verbose --file "${PROJECT}/src/macos/Brewfile"
    brew bundle install --file "${MACOS_DIR}/Brewfile"
    /usr/local/opt/fzf/install \
        --key-bindings \
        --completion \
        --no-update-rc
}

main() {
    step_home_brew_stuff
    ansible-playbook "${ANSIBLE_DIR}/setup-macos.yml"
    echo "Done :-)"
}

main
