#!/usr/bin/env bash

#
# Updates my asdf install.
#
# https://puppycrawl.com/blog/2023/01/12/asdf.html
#

set -euo pipefail

# Ensure sensible configuration file
rcfile=~/.asdfrc
echo Checking $rcfile...
test -f $rcfile || touch $rcfile
if [[ $(grep -c legacy_version_file $rcfile) = 0 ]]; then
    echo ...adding 'legacy_version_file = yes'
    echo 'legacy_version_file = yes' >> $rcfile
fi

# Update installed plugins
echo Updating installed plugins...
asdf plugin-update --all > /dev/null

# Ensure all the plugins are installed
echo Checking plugins are installed...
for n in java kotlin gradle python poetry nodejs; do
    if asdf plugin-list | grep -cq $n; then
        true # Already installed
    else
        echo ...installing $n
        echo asdf plugin-add $n
    fi
done

echo Updating versions...
# Special Java logic
asdf install java latest:temurin-11
asdf install java latest:corretto-17
asdf global java latest:corretto-17

# Special Nodejs logic
asdf install nodejs lts
asdf global nodejs lts

# The nice ones
for n in gradle kotlin python poetry; do
    asdf install $n latest
    asdf global $n latest
done

echo ...done
echo -------------
echo 'Need to run `asdf uninstall <tool> <old-version>` as necessary'
