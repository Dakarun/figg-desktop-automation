#!/usr/bin/env bash

set -e

read -p "This script will install zsh and ohmyzsh. The scripts in this repository will assume that zsh is your default shell. If you do NOT want to use zsh as your default shell, input n [y/n]" ANSWER
case $ANSWER in
  [Yy]* ) echo "Running script"; break;;
  [Nn]* ) echo "Exiting script"; exit;;
  * ) echo "Didn't receive Y/y, exiting"; exit;;
esac

# Install base packages
apt install awscli default-jdk git htop zsh

# Install oh-my-zsh
echo "Installing oh-my-zsh"
if [[ -z $ZSH ]]; then
  echo "zsh is already installed, skipping"
else
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install tfenv
echo "Installing tfenv"
if [[ -d "~/.tfenv" ]]; then
  echo "tfenv is already installed, skipping"
else
  git clone https://github.com/tfutils/tfenv.git ~/.tfenv
  echo -e '\n# tfenv variables' >> ~/.zshrc
  echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.zshrc
  echo "# tfenv variables end" >> ~/.zshrc
fi

# TODO: Add functionality to clean whatever these script install
