# Dotfiles

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

### Installing source files

It's as simple as running:

```bash
./install.sh
```

From this top-level directory.

I've extended the install.sh script to handle .config directory, too. Just create a directory named '_config' and add files or directories in this directory. Everything inside _config will be symlinked to .config.

## Homebrew on macOS

There is a `Brewfile` generated from/for [Homebrew Bundle](https://github.com/Homebrew/homebrew-bundle) as described at [Thoughtbot's blog](https://thoughtbot.com/blog/brewfile-a-gemfile-but-for-homebrew.)
