#!/usr/bin/env bash

set -euo pipefail

##
## Installs the dotfiles into $HOME by making soft linking to them.
## Existing files are backed up.
##

# @see: http://wiki.bash-hackers.org/syntax/shellvars
[ -z "${SCRIPT_DIRECTORY:-}" ] \
    && SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

##
## Links source file into target directory.
## Makes backup if target link already exists.
##
## @param $1 source script
## @param $2 target directory
##
function link_file() {
    local source="${1:-}"

    if [[ -z "${source}" ]]; then
        ehco "First argument of link_file must ot be empty!"
        exit 1
    fi

    local target_dir="${2:-}"

    if [[ -z "${target_dir}" ]]; then
        ehco "Second argument of link_file must ot be empty!"
        exit 1
    fi

    local target="${source##*/}"
    target="${target/_/.}"
    target="${target_dir}/${target}"

    echo "  ${source} -> ${target}"

    # Only create backup if target is a file or directory
    if [ -f "${target}" ] || [ -d "${target}" ]; then
        if [ ! -L "${target}" ]; then
            echo "Backing up ${target}"
            mv -v "${target}" "${target}.bak"
        fi
    fi

    ln -sf "${source}" "${target}"
}

main() {
    local base_dir
    base_dir="$(dirname "${SCRIPT_DIRECTORY}")"
    local source_dir="${base_dir}/src/dotfiles"
    local target_dir="${1:-}"

    if [[ -z "${target_dir}" ]]; then
        echo "No target dir given! Using \$HOME instead."
        target_dir="${HOME}"
    fi

    echo "Will install dotfiles into: ${target_dir}"

    read -rep "Proceed? [y/N]" answer

    if [[ "y" != "${answer}" ]] && [[ "Y" != "${answer}" ]]; then
        echo "Aborted!"
        exit 0
    fi

    echo "Installing dotfiles ..."

    for file in "${source_dir}/_"*; do
        link_file "${file}" "${target_dir}"
    done

    echo "Finished :)"
}

main "${1:-}"
