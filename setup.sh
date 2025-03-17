#!/bin/bash

# Define variables
DOTFILES_DIR="$HOME/repos/dotfiles"
BACKUP_DIR="$HOME/dotfiles_backup"
GENERIC_CONFIG_FILES=(".vimrc" ".gitconfig") # Add your dotfiles here

# Function to create a backup of existing dotfiles
backup_generic_dotfiles() {
  echo "Creating backup of existing dotfiles..."
  mkdir -p "$BACKUP_DIR"
  for file in "${GENERIC_CONFIG_FILES[@]}"; do
    if [ -f "$HOME/$file" ]; then
      echo "Backing up $file to $BACKUP_DIR"
      mv "$HOME/$file" "$BACKUP_DIR/"
    fi
  done
  echo "Backup completed."
}

# Function to install and setup zsh with personal configuration
install_zsh() {
  echo "Installing zsh..."
  # Check if zsh is installed
  if ! command -v zsh &>/dev/null; then
    echo "zsh not found. Installing zsh..."
    # Add commands to install zsh here
    # Example: sudo apt update && sudo apt install -y zsh
    brew install zsh
  else
    echo "zsh is already installed."
  fi

  if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh is already installed."
  else
    echo "Oh My Zsh is not installed."
    # Install oh-my-zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    # Install Powerlevel10k theme
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k
    # Install zsh-autosuggestions, zsh-syntax-highlighting and zsh-completions
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-completions.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-completions
  fi
    # copy config files
    cp "$DOTFILES_DIR"/shell/zshrc "$HOME"/.zshrc
    cp "$DOTFILES_DIR"/shell/p10k.zsh "$HOME"/.p10k.zsh
    cp "$DOTFILES_DIR"/shell/aliases.zsh "$ZSH_CUSTOM"/aliases.zsh
    # change default shell to zsh
    chsh -s "$(which zsh)"
    echo "zsh installed and configured."
}

# Function to deploy dotfiles
deploy_generic_dotfiles() {
  echo "Deploying dotfiles..."
  for file in "${GENERIC_CONFIG_FILES[@]}"; do
    if [ -f "$DOTFILES_DIR/$file" ]; then
      echo "Linking $file"
      ln -sf "$DOTFILES_DIR/$file" "$HOME/$file"
    else
      echo "Warning: $file not found in $DOTFILES_DIR"
    fi
  done
  echo "Dotfiles deployed."
}

# Function to install dependencies
install_dependencies() {
  echo "Installing dependencies..."
  # Add commands to install dependencies here
  # Example: sudo apt update && sudo apt install -y vim git
  #
  # Check if Homebrew is installed
  if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    echo "Homebrew is already installed."
  fi
  # fzf and zoxide:
  if ! brew list fzf &>/dev/null; then
    echo "fzf not found. Installing fzf..."
    brew install fzf
  else
    echo "fzf is already installed."
  fi

  if ! brew list zoxide &>/dev/null; then
    echo "zoxide not found. Installing zoxide..."
    brew install zoxide
  else
    echo "zoxide is already installed."
  fi
  echo "Dependencies installed."
}

# Main menu
main() {
  echo "Dotfiles Setup Script"
  echo "1) Backup existing dotfiles"
  echo "2) Deploy generic dotfiles"
  echo "3) Install dependencies"
  echo "4) Exit"
  read -rp "Choose an option: " choice

  case $choice in
    1) backup_generic_dotfiles ;;
    2) deploy_generic_dotfiles ;;
    3) install_dependencies ;;
    4) echo "Exiting..."; exit 0 ;;
    *) echo "Invalid option"; main ;;
  esac
}

# Run the main menu
main