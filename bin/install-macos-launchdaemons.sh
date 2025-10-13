#!/usr/bin/env bash

set -euo pipefail

# @see: http://wiki.bash-hackers.org/syntax/shellvars
[ -z "${SCRIPT_DIRECTORY:-}" ] &&
    SCRIPT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

PROJECT_DIR="$(dirname "${SCRIPT_DIRECTORY}")"
SRC_DIR="${PROJECT_DIR}/src"
MACOS_DIR="${SRC_DIR}/macos"
LAUNCH_AGENTS_DIR="${HOME}/Library/LaunchAgents"

PLIST_FILES=(
    "de.weltraumschaf.colima-aarch64.plist"
    "de.weltraumschaf.colima-x86.plist"
)

for plist_file in "${PLIST_FILES[@]}"; do
    launchctl unload "${LAUNCH_AGENTS_DIR}/${plist_file}"
    ln -svf "${MACOS_DIR}/${plist_file}" "${LAUNCH_AGENTS_DIR}/${plist_file}"
done
