#!/usr/bin/env bash

# logging
function e_header() { echo -e "\n\033[1m$@\033[0m"; }

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `freshinstall` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

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
mas signin --dialog $appleid

e_header '💾 Installing Applications and command line tools'
# restore installed apps
brew bundle
sudo xcodebuild -license accept

 # First, add the new shell to the list of allowed shells.
sudo bash -c 'echo /usr/local/bin/bash >> /etc/shells'
 # Change to the new shell.
chsh -s /usr/local/bin/bash 
# exec su - $USER

open -a 'Backup and Sync from Google'

brew install https://raw.github.com/gleitz/howdoi/master/howdoi.rb
go get github.com/cespare/reflex
pip3 install coala-bears

# Remove outdated versions from the cellar.
brew cleanup

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

if ( ! dialog --yesno "Did you restore the Mackup folder from google drive?" 6 30) then
    return;
fi;

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
archey -c
EOT

# Add the new shell to the list of legit shells
sudo bash -c "echo /usr/local/bin/bash >> /private/etc/shells"
# Change the shell for the user
chsh -s /usr/local/bin/bash
# Check for Bash 4 and /usr/local/bin/bash...
echo $BASH && echo $BASH_VERSION

e_header '✅ Making sure you are using the latest node'
n latest

sudo chown -R $USER /usr/local/n/

e_header '💪 Updates NPM'
npm update -g npm

e_header '🍉 Installing global node modules'

#node stuff
npm_globals=(
  gulp-cli
  vue-cli
  svgo
  jshint
)

for npmglobal in "${npm_globals[@]}"
do
  sudo npm install -g ${npmglobal};
done

e_header '✅ Makes sure you are using the most recent version of BASH'
sudo -s
echo /usr/local/bin/bash >> /etc/shells
chsh -s /usr/local/bin/bash

# Switch to using brew-installed bash as default shell
if ! fgrep -q '/usr/local/bin/bash' /etc/shells; then
  echo '/usr/local/bin/bash' | sudo tee -a /etc/shells;
  chsh -s /usr/local/bin/bash;
fi;

# make sure seeyouspacecowboy is called on EXIT
echo 'sh ~/.dotfiles/seeyouspacecowboy.sh; sleep 2' >> ~/.bash_logout

# loads the brand new bash_profile
source ~/.bash_profile

# updates all apps and stuff
update

if ( dialog --yesno "Do you wish to have a 'Sites' folder?" 6 30) then
e_header '💾 Creating Sites folder'
mkdir ~/Sites/
# makes sure mackup config is correct before restoring backup
cat >/etc/apache2/users/${USER}.conf <<'EOT'
<Directory "/Users/$USER/Sites/">
	AllowOverride All
	Options Indexes MultiViews FollowSymLinks
	Require all granted
</Directory>
EOT

sudo chmod 644 /etc/apache2/users/${USER}.conf

sudo apachectl start
fi;

e_header '🍺 you did it! 🍺'

# byebye
. seeyouspacecowboy.sh

