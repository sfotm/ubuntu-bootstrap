#!/usr/bin/env bash
# 
# Bootstrap script for setting up a new Ubuntu machine
# 
# This should be idempotent so it can be run multiple times.
#
# Notes:
# - This assumes that firefox is already installed
# - This assumes that GitHub is accessible and you are able
#       to clone repositories without issues (presumably that's
#       how you downloaded this...)
# - As-is, this is more of a GUIDE than a real run-it-once script.
#       Some of these items aren't idempotent and aren't worth spinning
#       up a new instance to test.
echo "Starting bootstrapping"

# Update apt
sudo apt update

# I'm leaning toward using ap packages when able,
# but some packages focus toward snap releases or
# do not exist in apt at all.
APT_PACKAGES=(
    audacity
    build-essential
    curl
    evolution
    gcc
    git
    jq
    neovim
    ripgrep
    vim
    wget
    zsh
)
echo "Installing apt packages..."
sudo apt install ${APT_PACKAGES[@]}

echo "Configuring Firefox..."
./firefox/set-up-firefox-profile.sh benjamin

# https://ohmyz.sh/#install
echo "Installing oh-my-zsh..."
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Downloading repositories..."
[[ ! -d ~/Source ]] && mkdir ~/Source
REPOSITORIES=(
    sfotm/dotfiles
    sfotm/sfotm.github.io
)
for repo in "${REPOSITORIES[@]}"
do
    mkdir -p ~/Source/$repo
    git clone https://github.com/$repo.git ~/Source/$(basename $repo)
done

# Apply dotfiles
## Delete the default ~/.zshrc that oh-my-zsh creates before applying dotfiles
rm ~/.zshrc
~/Source/dotfiles/install

# Ensure that dotfiles take effect
source ~/.zshrc

# https://github.com/pyenv/pyenv-installer
echo "Installing and configuring pyenv..."
curl https://pyenv.run | bash
pyenv install 3.9.7
pyenv global 3.9.7

echo "Installing and configuring rbenv..."
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
rbenv install 2.7.4
rbenv global 2.7.4

echo "Installing and configuring nvm..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
nvm install node

echo "Bootstrapping complete"
