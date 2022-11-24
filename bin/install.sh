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
## Extracts the base name from given path and replaces _ with .
##
## @param $1 file path
##
function convert_to_target() {
    local source="${1:-}"
    local sub_dir="${source##*/}"
    echo "${sub_dir/_/.}"
}

##
## Links source file into sub_dir directory.
## Makes backup if sub_dir link already exists.
##
## @param $1 source script
## @param $2 sub_dir directory
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

    local sub_dir
    sub_dir="$(convert_to_target "${source}")"
    sub_dir="${target_dir}/${sub_dir}"

    # Only create backup if sub_dir is a file or directory
    if [ -f "${sub_dir}" ] || [ -d "${sub_dir}" ]; then
        if [ ! -L "${sub_dir}" ]; then
            echo "Backing up ${sub_dir}"
            mv -v "${sub_dir}" "${sub_dir}.bak"
        fi
    fi

    ln -svf "${source}" "${sub_dir}"
}

main() {
    local base_dir
    base_dir="$(dirname "${SCRIPT_DIRECTORY}")"
    local source_dir="${base_dir}/src/dotfiles"
    local target_dir="${1:-}"

    if [[ -z "${target_dir}" ]]; then
        echo "No sub_dir dir given! Using \$HOME instead."
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
        if [[ -d "${file}" ]]; then
            local sub_dir
            sub_dir="$(convert_to_target "${file}")"
            mkdir -pv "${target_dir}/${sub_dir}"

            for sub_file in "${file}/"*; do
                link_file "${sub_file}" "${target_dir}/${sub_dir}"
            done
        else
            link_file "${file}" "${target_dir}"
        fi
    done

    echo "Finished :)"
}

main "${1:-}"
