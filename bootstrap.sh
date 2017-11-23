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

echo "--> Customising iTerm settings..."

echo "--> Disabling the bell..."
if ! /usr/libexec/PlistBuddy \
  -c "print 'New Bookmarks':0:'Silence Bell'" \
  ~/Library/Preferences/com.googlecode.iterm2.plist | grep -q 'true'; then
  /usr/libexec/PlistBuddy -c "Set 'New Bookmarks':0:'Silence Bell' true" ~/Library/Preferences/com.googlecode.iTerm2.plist
  /usr/libexec/PlistBuddy -c "Set 'New Bookmarks':0:'Visual Bell' false" ~/Library/Preferences/com.googlecode.iTerm2.plist
fi

echo "--> Map alt+left and alt+right key combinations to word skip left and right..."
if ! /usr/libexec/PlistBuddy \
  -c "print :'New Bookmarks':0:'Keyboard Map':'0xf702-0x280000':Text" \
  ~/Library/Preferences/com.googlecode.iterm2.plist 2>&1 | egrep -q '^b$'; then
  /usr/libexec/PlistBuddy -c "Set :'New Bookmarks':0:'Keyboard Map':'0xf702-0x280000':Text 'b'" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set :'New Bookmarks':0:'Keyboard Map':'0xf702-0x280000':Action 10" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set :'New Bookmarks':0:'Keyboard Map':'0xf703-0x280000':Text 'f'" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set :'New Bookmarks':0:'Keyboard Map':'0xf703-0x280000':Action 10" ~/Library/Preferences/com.googlecode.iterm2.plist
fi

echo "--> Map cmd+backspace key combination to word delete..."
if ! /usr/libexec/PlistBuddy \
  -c "print :'New Bookmarks':0:'Keyboard Map':'0x7f-0x100000':Text" \
  ~/Library/Preferences/com.googlecode.iterm2.plist 2>&1 | egrep -q '^0x1B 0x08$'; then
  /usr/libexec/PlistBuddy -c "Add :'New Bookmarks':0:'Keyboard Map':'0x7f-0x100000' dict" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add :'New Bookmarks':0:'Keyboard Map':'0x7f-0x100000':Text string" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set :'New Bookmarks':0:'Keyboard Map':'0x7f-0x100000':Text '0x1B 0x08'" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add :'New Bookmarks':0:'Keyboard Map':'0x7f-0x100000':Action integer" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set :'New Bookmarks':0:'Keyboard Map':'0x7f-0x100000':Action 11" ~/Library/Preferences/com.googlecode.iterm2.plist
fi

echo "--> Installing AppStore updates..."
sudo softwareupdate -ia
