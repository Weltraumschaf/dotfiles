#!/usr/bin/env bash

set -euo pipefail

##
## Installs the dotfiles into $HOME by making soft linking to them.
## Existing files are backed up.
##

# @see: http://wiki.bash-hackers.org/syntax/shellvars
[ -z "${SCRIPT_DIRECTORY:-}" ] \
    && SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

BASE_DIR="$(dirname "${SCRIPT_DIRECTORY}")"
SOURCE_DIR="${BASE_DIR}/src/dotfiles"

##
## Links source file into target directory.
## Makes backup if target link already exists.
##
## @param $1 source script
## @param $2 target directory
##
function link_file {
    local source="${1:-}"

    if [[ -z "${source}" ]]; then
        ehco "First argument of link_file must ot be empty!"
        exit 1
    fi

    local target_directory="${2:-}"

    if [[ -z "${target_directory}" ]]; then
        ehco "Second argument of link_file must ot be empty!"
        exit 1
    fi

    local target="${source##*/}"
    target="${target/_/.}"
    target="${target_directory}/${target}"

    echo "${source} --> ${target}"

    # Only create backup if target is a file or directory
    if [ -f "${target}" ] || [ -d "${target}" ]; then
        if [ ! -L "${target}" ]; then
            echo "Backing up ${target}"
            mv -v "${target}" "${target}.bak"
        fi
    fi

    ln -svf "${source}" "${target}"
}

echo "Installing dotfiles ..."

for file in "${SOURCE_DIR}/_"*; do
    link_file "${file}" "${HOME}"
done

echo "Finished :)"
