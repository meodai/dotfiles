# dotfiles
I stole my dotfiles from all over the place <3 

## Installation

```bash
cd ~
git clone git@github.com:meodai/dotfiles.git .dotfiles
# backup your bash profile
cat .bash_profile > .bash_profile.backup
```

replace contents of `.bash_profile` with
```bash
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
```
