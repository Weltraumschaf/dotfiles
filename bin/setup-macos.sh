#!/usr/bin/env bash

set -euo pipefail

# @see: http://wiki.bash-hackers.org/syntax/shellvars
[ -z "${SCRIPT_DIRECTORY:-}" ] \
    && SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

BASE_DIR="$(dirname "${SCRIPT_DIRECTORY}")"

step_home_brew_stuff() {
    if [ -n "${SKIP_HOME_BREW_STUFF}" ] && [ -z "${DO_HOME_BREW_STUFF}" ]; then return 0; fi

    if [ -x /usr/local/bin/brew ] ; then
        log "Homebrew already installed!"
        brew update && brew update && brew upgrade && brew upgrade --cask && brew cleanup
    else
        log "Install homebrew..."
        (curl -sSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash)
    fi

    log "Install basics with homebrew..."
    # https://thoughtbot.com/blog/brewfile-a-gemfile-but-for-homebrew
    # Write the Brewfile: brew bundle dump --describe --force --verbose --file "${PROJECT}/src/macos/Brewfile"
    brew bundle install --file "${BASE_DIR}/Brewfile"
    /usr/local/opt/fzf/install \
        --key-bindings \
        --completion \
        --no-update-rc
}

main() {
    step_home_brew_stuff
    echo "Done :-)"
}
