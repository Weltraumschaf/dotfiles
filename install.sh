#!/usr/bin/env bash

set -eu

##
## Intsalls the dotfiles into $HOME by softlinking them.
## Existing files are backupped.
##

# @see: http://wiki.bash-hackers.org/syntax/shellvars
[ -z "${SCRIPT_DIRECTORY:-}" ] \
    && SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )" \
    && export SCRIPT_DIRECTORY

sourceDir=$(realpath "${SCRIPT_DIRECTORY}")
sourceDir=$(dirname "${sourceDir}")
sourceDir="${sourceDir}/src"

##
## Links source file into target directory.
## Makes backup if target link already exists.
##
## @param $1 source script
## @param $2 target direcotry
##
function link_file {
    source="${1}"
    target="${source##*/}"
    target="${target/_/.}"
    target="${2}/${target}"

    echo "Install ${source} to ${target} ..."

    # Only create backup if target is a file or directory
    if [ -f "${target}" ] || [ -d "${target}" ]; then
        if [ ! -L "${target}" ]; then
            echo "Backing up ${target}"
            mv -v "${target}" "${target}.bak"
        fi
    fi

    ln -svf "${source}" "${target}"
}

for file in "${sourceDir}/_"*; do
  link_file "${file}" "${HOME}"
done

echo "Finished :)"
