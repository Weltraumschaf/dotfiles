#!/usr/bin/env bash

##
## Uninstalls the scripts from $HOME by removing the symlinks.
##

# @see: http://wiki.bash-hackers.org/syntax/shellvars
[ -z "${SCRIPT_DIRECTORY:-}" ] \
    && SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )" \
    && export SCRIPT_DIRECTORY

sourceDir="${SCRIPT_DIRECTORY}/src"

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

    rm -v "${target}"
}

for file in "${sourceDir}/_"*; do
  unlinkFile "${file}" "${HOME}"
done

echo "Finished :)"
