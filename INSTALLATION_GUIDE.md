# Manolo's Ultimate Lightweight Arch Linux Installation Guide

## Overview

This guide walks you through setting up a complete Arch Linux system with Hyprland, Zsh, and a comprehensive development environment using the enhanced `manolos_ultimate_lightweight_arch` Makefile.

**Features:**
- 🎮 **Automatic GPU Detection** - Installs appropriate drivers for NVIDIA, AMD, Intel, or VM systems
- 🖥️ **Hyprland Window Manager** - Modern Wayland-based tiling window manager
- 🐚 **Zsh + Oh My Zsh** - Enhanced shell with plugins and themes
- 🎨 **Complete Theming** - Consistent dark theme across all applications
- 🔧 **Development Tools** - Git, Neovim, Docker, and more
- 🔊 **Audio/Bluetooth** - PipeWire audio system with Bluetooth support

## System Requirements

- **Architecture:** x86_64
- **Storage:** At least 20GB free space
- **Memory:** Minimum 4GB RAM (8GB recommended)
- **Network:** Internet connection for package downloads
- **Access:** Root/sudo privileges

## Prerequisites

- Fresh Arch Linux installation (base system only)
- Active internet connection
- User account with sudo privileges

---

## Step 1: Fresh Arch Linux Installation

If you haven't installed Arch Linux yet, follow the official installation guide. Stop after the base system installation and reboot.

## Step 2: Connect to WiFi

Use `iwdctl` (modern replacement for `iwctl`) to connect to WiFi:

```bash
# Start iwd service
sudo systemctl start iwd

# List available networks
iwctl station wlan0 scan
iwctl station wlan0 get-networks

# Connect to your network
iwctl --passphrase [password] station wlan0 connect [network_name]

# Verify connection
ping -c 4 archlinux.org
```

**Alternative (if using NetworkManager):**
```bash
# Enable NetworkManager
sudo systemctl enable --now NetworkManager

# Use nmtui (text interface) or nmcli
nmtui
```

## Step 3: Install Essential Tools

```bash
# Update system
sudo pacman -Syu

# Install required tools for the setup process
sudo pacman -S --needed git make wget base-devel stow

# Verify installation
git --version && make --version && wget --version
```

## Step 4: Clone the Repository

```bash
# Create working directory
mkdir -p ~/setup
cd ~/setup

# Clone the repository
git clone https://github.com/ManoloEsS/dotfiles_arch_hypr.git

# Navigate to the packages directory
cd dotfiles_arch_hypr/packages
```

## Step 5: Verify the Setup

```bash
# Check that the Makefile exists
ls -la manolos_ultimate_lightweight_arch

# Test GPU detection
make -f manolos_ultimate_lightweight_arch detect-hardware

# View help for all available options
make -f manolos_ultimate_lightweight_arch help
```

## Step 6: Run Complete Installation

```bash
# Execute the full installation
make -f manolos_ultimate_lightweight_arch all
```

### What Happens During Installation

The `make all` command performs these steps automatically:

1. **📦 Clone Dotfiles** - Downloads configuration files
2. **🎮 Detect Hardware** - Identifies GPU and selects drivers
3. **💾 Install Packages** - Installs 350+ packages including:
   - Core system utilities
   - GPU drivers (auto-detected)
   - Development tools (Git, Neovim, Docker, etc.)
   - Desktop environment (Hyprland, Waybar, etc.)
   - Audio/Bluetooth support
4. **⚙️ Configure Shell** - Sets up Oh My Zsh with plugins
5. **🏠 Setup Configs** - Stows all configuration files
6. **🔌 Enable Services** - Configures Bluetooth and audio
7. **✅ Verify Installation** - Checks everything is working

### Installation Time Expectations
- **Package Downloads:** 15-30 minutes (depends on internet speed)
- **Installation Process:** 20-40 minutes (depends on hardware)
- **Total Time:** 45-90 minutes

## Step 7: Post-Installation

### 7.1 Reboot System

```bash
# Reboot to apply all changes
sudo reboot
```

### 7.2 Start Desktop Environment

After rebooting, login to your user account and run:

```bash
# Launch Hyprland
startx
```

**First Run Notes:**
- Hyprland will start with default keybindings
- Powerlevel10k configuration wizard may run in terminal
- Allow a few minutes for all services to initialize

### 7.3 Verify Everything Works

In your new Hyprland session:

```bash
# Check shell
echo $SHELL
# Should output: /usr/bin/zsh

# Check GPU drivers
glxinfo -B | grep "OpenGL renderer"
# Should show your GPU information

# Check audio
pactl info | grep "Default Sink"
# Should show audio device

# Check Bluetooth
bluetoothctl --version
# Should show Bluetooth version
```

## Manual Installation Options

If you prefer to run installation steps individually:

```bash
# Hardware detection only
make -f manolos_ultimate_lightweight_arch detect-hardware

# Package installation only
make -f manolos_ultimate_lightweight_arch install-packages

# Shell setup only
make -f manolos_ultimate_lightweight_arch install-ohmyzsh setup-ohmyzsh-plugins change-shell

# Config setup only
make -f manolos_ultimate_lightweight_arch cleanup-and-stow

# Verification only
make -f manolos_ultimate_lightweight_arch verify-complete-setup
```

## Troubleshooting

### Common Issues

#### 1. GPU Driver Issues
```bash
# Re-detect GPU and reinstall drivers
make -f manolos_ultimate_lightweight_arch detect-hardware
cat /tmp/gpu_drivers.txt

# Manual driver installation
sudo pacman -S xf86-video-amdgpu vulkan-radeon  # For AMD
sudo pacman -S nvidia nvidia-utils nvidia-dkms   # For NVIDIA
sudo pacman -S xf86-video-intel vulkan-intel     # For Intel
```

#### 2. Display Won't Start
```bash
# Check X server logs
cat ~/.local/share/xorg/Xorg.0.log | grep -i error

# Try generic drivers
sudo pacman -S xf86-video-vesa
```

#### 3. Audio Not Working
```bash
# Check PipeWire services
systemctl --user status pipewire pipewire-pulse wireplumber

# Restart audio services
systemctl --user restart pipewire pipewire-pulse wireplumber

# Test audio
speaker-test -c 2 -t wav
```

#### 4. Bluetooth Issues
```bash
# Check Bluetooth service
sudo systemctl status bluetooth

# Restart Bluetooth
sudo systemctl restart bluetooth

# Scan for devices
bluetoothctl scan on
```

#### 5. Stow Configuration Issues
```bash
# Remove conflicting configs manually
rm -rf ~/.config/hypr ~/.config/waybar ~/.config/wofi

# Restow configurations
cd ~/dotfiles_arch_hypr
stow -d ~/dotfiles_arch_hypr -t ~ hypr waybar wofi
```

### Getting Help

If you encounter issues:

1. **Check Logs:** Most errors are logged to `/var/log/` or `~/.local/share/`
2. **Run Verification:** `make -f manolos_ultimate_lightweight_arch verify-complete-setup`
3. **Individual Steps:** Try running installation steps individually to isolate issues
4. **Manual Intervention:** Some packages may require manual configuration

## Customization

### Adding Custom Packages

Edit these files in the dotfiles repository:
- `packages/pkglist.txt` - Add Arch repository packages
- `packages/aurlist.txt` - Add AUR packages

### Modifying Configurations

All configuration files are in dotfiles directories:
- `hypr/.config/hypr/` - Hyprland and Wayland settings
- `zsh/.zshrc` - Shell configuration
- `waybar/.config/waybar/` - Status bar configuration
- `wezterm/.config/wezterm/` - Terminal settings

### GPU Driver Customization

The setup automatically detects and installs appropriate drivers, but you can override:

```bash
# Force specific drivers
echo "nvidia nvidia-dkms" > /tmp/gpu_drivers.txt
make -f manolos_ultimate_lightweight_arch install-packages
```

## Security Notes

- The setup downloads packages from official Arch repositories and AUR
- All operations require sudo privileges for system-wide changes
- Configurations are backed up before being replaced
- No personal data is sent to external servers during setup

## Performance Optimization

After installation, consider:

```bash
# Enable zram for compressed swap
sudo systemctl enable zram-generator

# Optimize package database
sudo pacman-optimize && sudo pacman -Scc

# Update all packages regularly
sudo pacman -Syu && yay -Syu
```

## Uninstallation

To remove the custom environment:

```bash
# Clean up packages (dangerous - removes everything)
# Use with caution!
sudo pacman -Rs $(cat ~/dotfiles_arch_hypr/packages/pkglist.txt)

# Restore original configs from backups
cp ~/.bashrc.backup.* ~/.bashrc 2>/dev/null || true
cp /etc/X11/xinitrc.backup.* /etc/X11/xinitrc 2>/dev/null || true

# Remove dotfiles
rm -rf ~/dotfiles_arch_hypr
```

---

## Quick Reference

### Essential Commands
```bash
# Launch desktop
startx

# Update system
sudo pacman -Syu && yay -Syu

# Configure Bluetooth
bluetoothctl

# Audio controls
pavucontrol

# Terminal
wezterm

# File manager
nautilus

# System monitor
btop

# Network settings
nmtui
```

### Default Keybindings (Hyprland)
- `MOD = SUPER (Windows key)`
- `MOD + Enter` - Launch terminal
- `MOD + D` - Launch app launcher (wofi)
- `MOD + Shift + Q` - Close window
- `MOD + SHIFT + C` - Exit Hyprland
- `MOD + [Arrow keys]` - Focus windows
- `MOD + SHIFT + [Arrow keys]` - Move windows
- `MOD + [1-9]` - Switch workspaces
- `MOD + SHIFT + [1-9]` - Move to workspace

### File Locations
- **Configurations:** `~/.config/`
- **Dotfiles:** `~/dotfiles_arch_hypr/`
- **Backups:** `~/.bashrc.backup.*`, `/etc/X11/xinitrc.backup.*`
- **Logs:** `~/.local/share/`

---

**Congratulations!** You now have a complete, customized Arch Linux system with Hyprland, automatic GPU drivers, and a comprehensive development environment.

For issues or contributions, visit: https://github.com/ManoloEsS/dotfiles_arch_hypr