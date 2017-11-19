# My dotfiles repo

This is my dotfiles repo. If you're not familiar with the concept, see [the
Github dotfiles page](https://dotfiles.github.io/).

## Components

- **bootstrap.sh**: the script which does all the magic, creates the symlinks
  for all the dotfiles in the `dotfiles` directory and installs various
  packages using Homebrew.
- **dotfiles/**: directory containing a bunch of dotfiles I use to personalise
  my system. For each file in this directory a symlink will be created in your
  home directory.
- **Brewfile**: lists the packages and casks to be installed using `brew bundle`.

## Usage

```sh
git clone https://github.com/stephengrier/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

This will do various hings including installing Homebrew, running `brew bundle`
to install various packages and casks listed in the `Brewfile`.

It will then create symlinks for each of the dotfiles in the `dotfiles`
directory into your home directory.

