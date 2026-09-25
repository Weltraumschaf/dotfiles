#!/usr/bin/env bash

set -euo pipefail

##
## Uninstalls the scripts from $HOME by removing the symlinks.
##

# @see: http://wiki.bash-hackers.org/syntax/shellvars
[ -z "${SCRIPT_DIRECTORY:-}" ] \
    && SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

BASE_DIR="$(dirname "${SCRIPT_DIRECTORY}")"
sourceDir="${BASE_DIR}/src/dotfiles"

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
## Removes the symlink at target directory that corresponds to source, but
## only if it is actually a symlink pointing at source. This never touches
## real files/directories left there by anything other than install.sh,
## e.g. unrelated content that other tools placed inside a shared
## directory such as .config, .gnupg or .claude.
##
## @param $1 source script
## @param $2 target directory
##
function unlink_file() {
    local source="${1:-}"
    local target_dir="${2:-}"
    local sub_dir
    sub_dir="$(convert_to_target "${source}")"
    local target="${target_dir}/${sub_dir}"

    if [ -L "${target}" ] && [ "$(readlink "${target}")" = "${source}" ]; then
        rm -v "${target}"
    fi
}

for file in "${sourceDir}/_"*; do
    if [[ -d "${file}" ]]; then
        sub_dir="$(convert_to_target "${file}")"
        target_sub_dir="${HOME}/${sub_dir}"

        for sub_file in "${file}/"*; do
            unlink_file "${sub_file}" "${target_sub_dir}"
        done

        # Only remove the shared directory itself (.config, .gnupg, ...)
        # once it is empty, i.e. once nothing but our own managed
        # symlinks lived in it. Leaves any unrelated content untouched.
        rmdir -v "${target_sub_dir}" 2>/dev/null || true
    else
        unlink_file "${file}" "${HOME}"
    fi
done

echo "Finished :)"
