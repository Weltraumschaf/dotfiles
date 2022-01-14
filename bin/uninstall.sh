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
## Removes link from target directory.
##
## @param $1 source script
## @param $2 target direcotry
##
function unlinkFile {
    targetFile="${1##*/}"
    targetFile="${targetFile/_/.}"
    target="${2}/${targetFile}"

    rm -vrf "${target}"
}

for file in "${sourceDir}/_"*; do
  unlinkFile "${file}" "${HOME}"
done

echo "Finished :)"
