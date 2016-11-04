#!/usr/bin/env bash

# logging
function e_header() { echo -e "\n\033[1m$@\033[0m"; }

cd ~/.dotfiles

# install homebrew if not already there
if [[ ! "$(type -P brew)" ]]; then
    e_header '🍳 Installing homebrew'
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

e_header '🍳 Updating homebrew'
brew doctor
brew update

brew install dialog

if ( ! dialog --yesno "Do you want to install meodai's ❣ .dotfiles?" 6 30) then
    return;
fi;

# tap Brew Bundle
e_header '📚 Installing Bundle'
brew tap Homebrew/bundle

e_header '🍎 Installing Mas'
brew install mas


e_header '🍏 Enter your apple id, followed by [ENTER]:'
read appleid
mas signin $appleid

e_header '💾 Installing Applications and command line tools'
# restore installed apps
brew bundle
e_header '💾 Installed all apps and tools from Brewfile'

e_header '💾 Creates mackup config file'
# makes sure mackup config is correct before restoring backup
cat >~/.mackup.cfg <<'EOT'
[storage]
engine = google_drive

[applications_to_ignore]
skype

[configuration_files]
.gitignore_global
.bash_profile
EOT


e_header '📦 Restores configs from mackup'
e_header '⌛ have a coffee this will take a while'
# restore mackup backup
mackup restore

e_header '💾 Creates a backup of you current .bash_profile'
# backup .bash_prfole
cat ~/.bash_profile > ~/.bash_profile.backup


e_header '🖌 Creates a new .bash_prfole'
# create new bash profile
cat >~/.bash_profile <<'EOT'
# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH";

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.dotfiles/.{export,bash_profile,alias,function}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# say -v "Zarvox" "hello {$USER}, I'm a new terminal" &
# Show archey on bootup
say -v "Zarvox" "new terminal" &
archey -c
EOT

e_header '✅ Making sure you are using the latest node'
sudo n latest

e_header '💪 Updates NPM'
npm update -g npm

e_header '🍉 Installing global node modules'

#node stuff
npm_globals=(
  peerflix
  node-inspector
  gulp-cli
  vue-cli
  svgo
)

for npmglobal in "${npm_globals[@]}"
do
  npm install -g ${npmglobal};
done

curl https://install.meteor.com/ | sh

# make sure seeyouspacecowboy is called on EXIT
echo 'sh ~/.dotfiles/seeyouspacecowboy.sh; sleep 2' >> ~/.bash_logout

# loads the brand new bash_profile
source ~/.bash_profile

e_header '✅ you did it!'

# byebye
. seeyouspacecowboy.sh

