#!/usr/bin/env bash
#
# Run all dotfile tasks.
set -e

if [ ! "$(which brew)" ];
then
  echo "--> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/stephen.grier/.profile
  eval "$(/opt/homebrew/bin/brew shellenv)"
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

echo "--> Creating per-workspace git configs..."
if [ ! -d ~/git ];
then
  mkdir ~/git
fi
gitworkconfig=~/git/.gitconfig;
if [ ! -f "${gitworkconfig}" ];
then
  printf '[user]\n    email = stephen.grier@digital.cabinet-office.gov.uk\n' > "${gitworkconfig}";
fi

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

echo "--> Setting a fast keyboard repeat rate..."
if ! defaults read NSGlobalDomain KeyRepeat 2>&1 | egrep -q '^2$'; then
  defaults write NSGlobalDomain KeyRepeat -int 2
  defaults write NSGlobalDomain InitialKeyRepeat -int 15
fi

echo "--> Setting autohide on the dock app..."
if defaults read com.apple.dock autohide | egrep -q '^0$'; then
  defaults write com.apple.dock autohide -bool true
fi

echo "--> Setting the date format on the clock..."
dateformat='EEE d MMM  HH:mm:ss'
if ! defaults read com.apple.menuextra.clock DateFormat | egrep -q "^${dateformat}$"; then
  defaults write com.apple.menuextra.clock DateFormat -string "${dateformat}"
fi

echo "--> Setting screensaver to immediately require a password..."
if ! defaults read com.apple.screensaver askForPasswordDelay | egrep -q '^0$'; then
  defaults write com.apple.screensaver askForPasswordDelay 0
fi

echo "--> Mapping caps lock key to escape..."
# https://developer.apple.com/library/archive/technotes/tn2450/_index.html
if ! hidutil property --get "UserKeyMapping" | egrep -q '30064771129'; then
  hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x700000029}]}'
fi

echo "--> Changing the default shell to Bash..."
# https://support.apple.com/en-gb/HT208050
if ! dscl . -read ~/ UserShell | egrep -q '/bin/bash$'; then
  chsh -s /bin/bash
 fi

echo "--> Installing AppStore updates..."
sudo softwareupdate -ia
