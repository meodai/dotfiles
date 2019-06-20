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

open -a 'Backup and Sync from Google'

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
  parcel-bundler
  svgo
  jshint
)

for npmglobal in "${npm_globals[@]}"
do
  sudo npm install -g ${npmglobal};
done

# make sure seeyouspacecowboy is called on EXIT
echo 'sh ~/.dotfiles/seeyouspacecowboy.sh; sleep 2' >> ~/.bash_logout

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

# add fish shell to the shells (was installed by brew)
echo “/usr/local/bin/fish” | sudo tee -a /etc/shells
# sets fish shell as default terminal 
chsh -s /usr/local/bin/fish
# install oh my fish 
curl -L https://get.oh-my.fish | fish

e_header '🍺 you did it! 🍺'

# byebye
. seeyouspacecowboy.sh

