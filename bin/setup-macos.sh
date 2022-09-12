#!/usr/bin/env bash

set -euo pipefail

# @see: http://wiki.bash-hackers.org/syntax/shellvars
[ -z "${SCRIPT_DIRECTORY:-}" ] \
    && SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# Pre Silicon
#HOMEBREW_PREFIX=/usr/local
# Silicon
HOMEBREW_PREFIX="/opt/homebrew"

PROJECT_DIR="$(dirname "${SCRIPT_DIRECTORY}")"
SRC_DIR="${PROJECT_DIR}/src"
MACOS_DIR="${SRC_DIR}/macos"
ANSIBLE_DIR="${SRC_DIR}/ansible"

step_home_brew_stuff() {
    echo "Setup home brew stuff..."

    if [ -x "${HOMEBREW_PREFIX}/bin/brew" ] ; then
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
    "${HOMEBREW_PREFIX}/opt/fzf/install" \
        --key-bindings \
        --completion \
        --no-update-rc
}

step_install_python() {
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"

    pyenv install 3.10.3
    pyenv install 3.10.4
    pyenv rehash
    pyenv global 3.10.4
}

main() {
    step_home_brew_stuff
    step_install_python
    ansible-playbook -K "${ANSIBLE_DIR}/setup-macos.yml"
    echo "Done :-)"
}

main
