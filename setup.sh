#!/bin/bash

# Function to check if chezmoi is installed
is_chezmoi_installed() {
  command -v chezmoi &>/dev/null
}

# Function to install chezmoi on macOS using Homebrew
install_on_macos() {
  echo "Installing chezmoi on macOS using Homebrew..."
  brew install chezmoi
}

# Function to install chezmoi on Android using pkg
install_on_android() {
  echo "Installing chezmoi on Android using pkg..."
  pkg install chezmoi git which
}

# Function to detect Linux distribution
detect_linux_distro() {
  if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    echo "$ID"
  elif [[ -d "/data/data/com.termux/files/usr" ]] || [[ -n "$TERMUX_VERSION" ]]; then
    echo "android"
  else
    echo "unknown"
  fi
}

# Function to determine the system architecture and map it to the correct format
get_architecture() {
  local distro="$1"
  case "$(uname -m)" in
  x86_64)
    if [[ "$distro" == "fedora" ]]; then
      echo "x86_64"
    else
      echo "amd64"
    fi
    ;;
  aarch64 | arm64)
    if [[ "$distro" == "fedora" ]]; then
      echo "aarch64"
    else
      echo "arm64"
    fi
    ;;
  *)
    echo "unsupported"
    ;;
  esac
}

# Function to install chezmoi on Debian-based systems
install_on_debian() {
  local arch=$(get_architecture "debian")

  if [[ "$arch" == "unsupported" ]]; then
    echo "Unsupported architecture."
    exit 1
  fi

  echo "Checking if chezmoi is available in apt repositories..."
  if apt-cache search ^chezmoi$ | grep -q ^chezmoi; then
    echo "Installing chezmoi from apt repository..."
    sudo apt update && sudo apt install -y chezmoi
  else
    echo "chezmoi is not in the apt repository, downloading and installing from chezmoi website..."
    # Fetch the latest chezmoi .deb file URL for the detected architecture
    deb_url=$(curl -s https://api.github.com/repos/twpayne/chezmoi/releases/latest | grep -oP "(?<=browser_download_url\": \")[^\"]*linux_${arch}\.deb")

    if [[ -n "$deb_url" ]]; then
      curl -Lo chezmoi.deb "$deb_url"
      sudo dpkg -i chezmoi.deb
      rm chezmoi.deb
      echo "chezmoi installed successfully."
    else
      echo "Failed to find the chezmoi .deb package for $arch architecture."
      exit 1
    fi
  fi
}

# Function to install chezmoi on Fedora-based systems
install_on_fedora() {
  local arch=$(get_architecture "fedora")

  if [[ "$arch" == "unsupported" ]]; then
    echo "Unsupported architecture."
    exit 1
  fi

  echo "Checking if chezmoi is available in dnf repositories..."
  if dnf list chezmoi &>/dev/null; then
    echo "Installing chezmoi from dnf repository..."
    sudo dnf install -y chezmoi
  else
    echo "chezmoi is not in the dnf repository, downloading and installing from chezmoi website..."
    # Fetch the latest chezmoi .rpm file URL for the detected architecture
    rpm_url=$(curl -s https://api.github.com/repos/twpayne/chezmoi/releases/latest | grep -oP "(?<=browser_download_url\": \")[^\"]*${arch}\.rpm")

    if [[ -n "$rpm_url" ]]; then
      curl -Lo chezmoi.rpm "$rpm_url"
      sudo dnf install -y chezmoi.rpm
      rm chezmoi.rpm
      echo "chezmoi installed successfully."
    else
      echo "Failed to find the chezmoi .rpm package for $arch architecture."
      exit 1
    fi
  fi
}

check_dependencies() {
  if ! command -v curl &>/dev/null; then
    echo "curl is required but not installed. Please install curl and rerun this script."
    exit 1
  fi
}

install_chezmoi() {
  if is_chezmoi_installed; then
    echo "chezmoi is already installed."
    chezmoi --version
    return
  fi

  case "$(uname -s)" in
  Darwin)
    install_on_macos
    ;;
  Linux)
    distro=$(detect_linux_distro)
    case "$distro" in
    debian | ubuntu)
      install_on_debian
      ;;
    fedora)
      install_on_fedora
      ;;
    android)
      install_on_android
      ;;
    *)
      echo "Unsupported Linux distribution: $distro"
      exit 1
      ;;
    esac
    ;;
  *)
    echo "Unsupported OS."
    exit 1
    ;;
  esac
}

add_shell_location() {
  mkdir -p $HOME/.config/chezmoi/ || true
  cat <<EOF >$HOME/.config/chezmoi/chezmoi.toml
[data]
  bash = "$(which bash)"
EOF
}

# Install chezmoi on system
check_dependencies
add_shell_location
install_chezmoi

# Init and apply
chezmoi init --branch main https://github.com/jeduardo/dotfiles.git
chezmoi apply -v
