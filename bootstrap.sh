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

echo "--> Linking files in ~/.gnupg..."
if [ ! -d ~/.gnupg ]; then
  mkdir ~/.gnupg
fi
for file in ~/.dotfiles/gnupg/*.conf; do
  target=~/.gnupg/$(basename $file)
  if [ ! -f "$target" ]; then
    ln -s "$file" "$target"
  fi
done

echo "--> Import GPG public keys..."
for file in ~/.dotfiles/gnupg/*.pem; do
  keyid=$(basename -s .pem "$file")
  if gpg -k "$keyid" 2>&1 | grep -q 'No public key'; then
    gpg --import --armor < "$file"
  fi
done


echo "--> Install vim pathogen..."
pathogenurl="https://raw.githubusercontent.com/tpope/vim-pathogen/master/autoload/pathogen.vim"
if [ ! -d ~/.vim/autoload ]; then
  mkdir -p ~/.vim/{autoload,bundle}
  curl -s $pathogenurl > ~/.vim/autoload/pathogen.vim
fi

echo "--> Install vim NERDTree..."
if [ ! -d ~/.vim/bundle/nerdtree ]; then
  git clone https://github.com/scrooloose/nerdtree.git ~/.vim/bundle/nerdtree
fi

echo "--> Installing AppStore updates..."
sudo softwareupdate -ia
