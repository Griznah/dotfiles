#!/bin/bash
# This script is used to setup dotfiles on a new system
# It can be used to backup existing dotfiles, install dependencies, deploy generic dotfiles and install zsh with personal configuration
# Author: Ole-Magnus Sæther aka Griznah - 2025-03-17

# Define variables
DOTFILES_DIR="$HOME/repos/dotfiles"
BACKUP_DIR="$HOME/dotfiles_backup"
GENERIC_CONFIG_FILES=("vimrc" "gitconfig") # Add your dotfiles here

# Function to create a backup of existing dotfiles
backup_generic_dotfiles() {
  echo "Creating backup of existing dotfiles..."
  mkdir -p "$BACKUP_DIR"
  for file in "${GENERIC_CONFIG_FILES[@]}"; do
    if [ -f "$HOME/.${file}" ]; then
      echo "Backing up .${file} to $BACKUP_DIR"
      cp "$HOME/.${file}" "$BACKUP_DIR/.${file}-$(date +%Y%m%d)"
    fi
  done
  echo "Backup completed."
}

# Function to ensure Homebrew is installed
ensure_homebrew_installed() {
  if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  else
    echo "Homebrew is already installed."
  fi
}

# Function to install and setup zsh with personal configuration
install_zsh() {
  echo "Installing zsh..."
  # Check if zsh is installed
  if ! command -v zsh &>/dev/null; then
    echo "zsh not found. Installing zsh..."
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    if ! command -v brew &>/dev/null; then
      echo "Homebrew is not installed. Please install Homebrew via dependencies choice and rerun this choice after."
      exit 1
    fi
    brew install zsh
  else
    echo "zsh is already installed."
  fi

  if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh is already installed."
  else
    echo "Oh My Zsh is not installed."
    # Install oh-my-zsh
    echo "You'll have to exit the Oh my Zsh after install for script to continue."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    # Install Powerlevel10k theme
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k
  fi
  # Define plugins to install
  ZSH_PLUGINS=(
    "zsh-users/zsh-autosuggestions"
    "zsh-users/zsh-syntax-highlighting"
    "zsh-users/zsh-completions"
  )
  # Install plugins if they do not already exist
  for plugin in "${ZSH_PLUGINS[@]}"; do
    plugin_name=$(basename "$plugin")
    plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin_name"
    if [ ! -d "$plugin_dir" ]; then
    echo "Installing $plugin_name..."
    git clone "https://github.com/$plugin" "$plugin_dir"
    else
    echo "$plugin_name is already installed."
    fi
  done
  # link config files
  ln -sf "$DOTFILES_DIR"/shell/zshrc "$HOME"/.zshrc
  ln -sf "$DOTFILES_DIR"/shell/p10k.zsh "$HOME"/.p10k.zsh
  ln -sf "$DOTFILES_DIR"/shell/aliases.zsh "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/aliases.zsh
  # change default shell to zsh, but first check if it's a valid choice
  if ! grep -q "$(command -v zsh)" /etc/shells; then
    command -v zsh | sudo tee -a /etc/shells
  fi
  chsh -s "$(which zsh)"
  echo "zsh installed and configured."
}

# Function to deploy dotfiles
deploy_generic_dotfiles() {
  echo "Deploying dotfiles..."
  for file in "${GENERIC_CONFIG_FILES[@]}"; do
    if [ -f "$DOTFILES_DIR/$file" ]; then
      echo "Linking $file"
      ln -sf "$DOTFILES_DIR/$file" "$HOME/.${file}"
    else
      echo "Warning: $file not found in $DOTFILES_DIR"
    fi
  done
  if printf '%s\n' "${GENERIC_CONFIG_FILES[@]}" | grep -q "vimrc"; then
    if [ ! -d "$HOME/.vim/bundle/Vundle.vim" ]; then
      echo "Vundle.vim not found. Cloning Vundle.vim..."
      git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
      vim +PluginInstall +qall
    else
      echo "Vundle.vim already exists."
    fi
    if [ -d "$DOTFILES_DIR/vim" ]; then
      echo "Copy contents of .vim directory"
      cp -r "$DOTFILES_DIR"/vim/* "$HOME/.vim/"
    else
      echo "Warning: vim directory not found in $DOTFILES_DIR"
    fi
  fi
  echo "Dotfiles deployed."
}

# Function to install common software I use
install_common_software() {
  echo "Installing dependencies..."
  ensure_homebrew_installed
  # List of software to install
  SOFTWARE_LIST=("fzf" "zoxide" "eza" "bat" "yq" "sd" "fd" "ripgrep" "httpie" "ncdu" "duf")

  for software in "${SOFTWARE_LIST[@]}"; do
    if ! brew list "$software" &>/dev/null; then
      echo "$software not found. Installing $software..."
      brew install "$software"
    else
      echo "$software is already installed."
    fi
  done

  echo "Dependencies installed."
}

# Function to install Kubernetes-related tools
install_devops_tools() {
  echo "Installing Kubernetes tools..."
  ensure_homebrew_installed
  # List of Kubernetes tools to install
  devops_tools=("argocd" "kubectl" "talosctl" "kustomize" "ansible" "opentofu")

  for tool in "${devops_tools[@]}"; do
    if ! brew list "$tool" &>/dev/null; then
      echo "$tool not found. Installing $tool..."
      brew install "$tool"
    else
      echo "$tool is already installed."
    fi
  done

  echo "Kubernetes tools installed."
}

# Main menu
main() {
  echo "Dotfiles Setup Script"
  echo "1) Backup existing dotfiles"
  echo "2) Install common software"
  echo "3) Deploy generic dotfiles (and some Vim plugins)"
  echo "4) Install and configure zsh"
  echo "8) Install Kubernetes tools"
  echo "9) Exit"
  read -rp "Choose an option: " choice

  case $choice in
    1) backup_generic_dotfiles ;;
    2) install_common_software ;;
    3) deploy_generic_dotfiles ;;
    4) install_zsh ;;
    8) install_devops_tools ;;
    9) echo "Exiting..."; exit 0 ;;
    *) echo "Invalid option"; main ;;
  esac
}

# Run the main menu
main
