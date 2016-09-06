#!/usr/bin/env bash

cd ~/.dotfiles

# get homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew install dialog

if ( ! dialog --title "!Warning!"  --yesno "Do you want to install meodai's .dotfiles?" 6 30) then
    return;
fi;

# tap Brew Bundle
brew tap Homebrew/bundle
# restore installed apps
brew bundle

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

# restore mackup backup
mackup restore

# backup .bash_prfole
cat ~/.bash_profile > ~/.bash_profile.backup

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

# creates a a symlink for EXIT script
rm ~/.seeyouspacecowboy.sh
ln -s $PWD/seeyouspacecowboy.sh ~/seeyouspacecowboy.sh

# make sure seeyouspacecowboy is called on EXIT
echo 'sh ~/seeyouspacecowboy.sh; sleep 2' >> ~/.bash_logout

# loads the brand new bash_profile
source ~/.bash_profile

# byebye
. seeyouspacecowboy.sh

