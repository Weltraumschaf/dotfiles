# Dotfiles

## Setup of a New Mac

1. install [Homebrew](https://brew.sh/): `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
1. install all brews:  `brew bundle install --file "src/macos/Brewfile"`
1. run Ansible playbook: `ansible-playbook --ask-become-pass src/ansible/setup-macos.yml`
1. install the dotfiles: `./bin/install.sh`

## Instructions

### Creating source files

Any file which matches the shell glob `_*` will be linked into `$HOME` as a symlink with the first `_`  replaced with a `.`

For example:

```bash
_bashrc
```

becomes

```bash
${HOME}/.bashrc
```

I've extended the `install.sh` script to handle `.config` directory, too. Just create a directory named `_config` and add files or directories in this directory. Everything inside `_config` will be symlinked to `.config`.

## Homebrew on macOS

There is a `Brewfile` generated from/for [Homebrew Bundle](https://github.com/Homebrew/homebrew-bundle) as described at [Thoughtbot's blog](https://thoughtbot.com/blog/brewfile-a-gemfile-but-for-homebrew).

### Update the Brewfile

```bash
brew bundle dump --describe --force
```
