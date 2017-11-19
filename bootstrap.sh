#!/usr/bin/env bash
#
# Run all dotfile tasks.
set -e

if [ ! "$(which brew)" ];
then
  echo "--> Installing Homebrew..."
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi;

echo "--> Updating Homebrew..."
brew update

echo "--> Installing brew packages..."
brew bundle

echo "--> Creating dotfile symlinks..."
for file in ~/.dotfiles/dotfiles/.* ;
do
  if [ -f "$file" ];
  then
    target=~/$(basename "$file")
    if [[ -e $target && ! -L $target ]];
    then
      read -rp "$target is a normal file, do you want to replace it? " replace
      case $replace in
        [y]* ) mv "$target" "${target}.bak"
          ln -s "$file" "$target"
        ;;
      esac
    elif [ ! -L "$target" ];
    then
      read -rp "Do you want to link $target? " replace
      case $replace in
        [y]* ) ln -s "$file" "$target"
        ;;
      esac
    elif [ -L "$target" ];
    then
      source=$(ls -l "$target" | awk '{print $11}')
      if [ "$file" != "$source" ];
      then
        read -rp "$target is symlinked to $source, do you want to symlink it to $file instead? " replace
        case $replace in
          [y]* ) mv "$target" "${target}.bak"
            ln -s "$file" "$target"
          ;;
        esac
      fi
    fi
  fi
done

echo "--> Installing AppStore updates..."
sudo softwareupdate -ia
