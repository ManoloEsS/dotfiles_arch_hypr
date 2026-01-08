# Makefile for Arch Linux Post-Installation Setup
# This Makefile automates the complete setup of a new Arch Linux installation

# Variables
DOTFILES_DIR := $(HOME)/dotfiles_arch_hypr
NVIM_CONFIG_DIR := $(XDG_CONFIG_HOME:-$(HOME)/.config)/nvim
STOW_DIRS := fontconfig hypr pl10k tmux waybar wezterm wofi zsh
DOTFILES_REPO := https://github.com/ManoloEsS/dotfiles_arch_hypr.git
NVIM_REPO := https://github.com/ManoloEsS/kickstartmanolo.nvim.git

# Phony targets
.PHONY: all install-gnome clone-dotfiles install-packages setup-nvim install-ohmyzsh setup-ohmyzsh-plugins change-shell stow-configs clean help

# Default target
all: clone-dotfiles install-packages setup-nvim install-ohmyzsh setup-ohmyzsh-plugins change-shell stow-configs
	@echo "=== Installation completed successfully! ==="
	@echo "Please restart your system or run 'startx' to begin using your new environment."

# Clone dotfiles repository
clone-dotfiles:
	@echo "=== Cloning dotfiles repository ==="
	@if [ -d "$(DOTFILES_DIR)" ]; then \
		echo "Dotfiles directory already exists, removing..."; \
		rm -rf $(DOTFILES_DIR); \
	fi
	mkdir -p $(DOTFILES_DIR) || exit 1
	wget -O - https://github.com/ManoloEsS/dotfiles_arch_hypr/archive/main.tar.gz | tar -xz -C $(DOTFILES_DIR)/.. --strip-components=1 || exit 1
	chmod +x $(DOTFILES_DIR)/packages/*.sh || exit 1
	@echo "=== Dotfiles cloned successfully ==="

# Install packages using the restore script
install-packages:
	@echo "=== Installing packages ==="
	@# Install yay first if not present
	@if ! command -v yay >/dev/null 2>&1; then \
		echo "Installing yay AUR helper..."; \
		git clone https://aur.archlinux.org/yay.git /tmp/yay || exit 1; \
		cd /tmp/yay && makepkg -si --noconfirm || exit 1; \
		rm -rf /tmp/yay; \
	fi
	@# Run the package restore script
	cd $(DOTFILES_DIR)/packages && ./arch_package_backup_and_restore.sh restore || exit 1
	@echo "=== Package installation completed ==="

# Setup Neovim configuration
setup-nvim:
	@echo "=== Setting up Neovim configuration ==="
	@if [ -d "$(NVIM_CONFIG_DIR)" ]; then \
		echo "Removing existing Neovim configuration..."; \
		rm -rf $(NVIM_CONFIG_DIR); \
	fi
	mkdir -p "$(NVIM_CONFIG_DIR)" || exit 1
	git clone $(NVIM_REPO) "$(NVIM_CONFIG_DIR)" || exit 1
	@echo "=== Neovim configuration completed ==="

# Setup Oh My Zsh plugins and themes
setup-ohmyzsh-plugins:
	@echo "=== Setting up Oh My Zsh plugins and themes ==="
	@# Ensure custom directories exist
	mkdir -p "$(HOME)/.oh-my-zsh/custom/plugins" || exit 1
	mkdir -p "$(HOME)/.oh-my-zsh/custom/themes" || exit 1
	@# Install zsh-syntax-highlighting plugin (from AUR, but let's ensure Oh My Zsh method)
	@if [ ! -d "$(HOME)/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then \
		echo "Installing zsh-syntax-highlighting plugin..."; \
		git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$(HOME)/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" || exit 1; \
	fi
	@# Install zsh-autosuggestions plugin (from pkglist, but ensure Oh My Zsh method)
	@if [ ! -d "$(HOME)/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then \
		echo "Installing zsh-autosuggestions plugin..."; \
		git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git "$(HOME)/.oh-my-zsh/custom/plugins/zsh-autosuggestions" || exit 1; \
	fi
	@# Install zsh-completions plugin (from AUR, but ensure Oh My Zsh method)
	@if [ ! -d "$(HOME)/.oh-my-zsh/custom/plugins/zsh-completions" ]; then \
		echo "Installing zsh-completions plugin..."; \
		git clone --depth=1 https://github.com/zsh-users/zsh-completions.git "$(HOME)/.oh-my-zsh/custom/plugins/zsh-completions" || exit 1; \
	fi
	@# Install fzf-tab plugin
	@if [ ! -d "$(HOME)/.oh-my-zsh/custom/plugins/fzf-tab" ]; then \
		echo "Installing fzf-tab plugin..."; \
		git clone --depth=1 https://github.com/Aloxaf/fzf-tab.git "$(HOME)/.oh-my-zsh/custom/plugins/fzf-tab" || exit 1; \
	fi
	@# Install Powerlevel10k theme
	@if [ ! -d "$(HOME)/.oh-my-zsh/custom/themes/powerlevel10k" ]; then \
		echo "Installing Powerlevel10k theme..."; \
		git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$(HOME)/.oh-my-zsh/custom/themes/powerlevel10k" || exit 1; \
	fi
	@echo "=== Setting up fzf fuzzy finder ==="
	@# Ensure fzf is installed (should be in pkglist)
	@if ! command -v fzf >/dev/null 2>&1; then \
		echo "Installing fzf package..."; \
		sudo pacman -S --noconfirm fzf || exit 1; \
	fi
	@# Setup fzf shell integrations
	@echo "Setting up fzf shell integrations..."
	@if [ -f "/usr/share/fzf/key-bindings.zsh" ] && [ -f "/usr/share/fzf/completion.zsh" ]; then \
		echo "source /usr/share/fzf/key-bindings.zsh" >> "$(HOME)/.zshrc" && \
		echo "source /usr/share/fzf/completion.zsh" >> "$(HOME)/.zshrc"; \
		echo "FZF key bindings and completion added to ~/.zshrc"; \
	else \
		echo "FZF shell files not found in /usr/share/fzf/"; \
	fi
	@echo "=== Oh My Zsh plugins and themes setup completed ==="

# Install Oh My Zsh
install-ohmyzsh:
	@echo "=== Installing Oh My Zsh ==="
	@if [ -d "$(HOME)/.oh-my-zsh" ]; then \
		echo "Removing existing Oh My Zsh installation..."; \
		rm -rf $(HOME)/.oh-my-zsh; \
	fi
	wget -O - https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh -s -- --unattended || exit 1
	@echo "=== Setting up Oh My Zsh custom directories ==="
	@# Create custom directories for plugins and themes
	mkdir -p "$(HOME)/.oh-my-zsh/custom/plugins" || exit 1
	mkdir -p "$(HOME)/.oh-my-zsh/custom/themes" || exit 1
	@echo "=== Oh My Zsh installation completed ==="

# Change default shell to zsh
change-shell:
	@echo "=== Changing default shell to zsh ==="
	@if command -v zsh >/dev/null 2>&1; then \
		if [ "$$SHELL" != "$(which zsh)" ]; then \
			echo $(which zsh) | sudo chsh $$USER || exit 1; \
			echo "Default shell changed to zsh"; \
		else \
			echo "Default shell is already zsh"; \
		fi; \
	else \
		echo "ERROR: zsh is not installed"; \
		exit 1; \
	fi
	@echo "=== Shell change completed ==="

# Stow all configuration directories
stow-configs:
	@echo "=== Stowing configuration directories ==="
	@# Ensure stow is installed
	@if ! command -v stow >/dev/null 2>&1; then \
		echo "Installing GNU Stow..."; \
		sudo pacman -S --noconfirm stow || exit 1; \
	fi
	@# Navigate to dotfiles directory and stow each directory
	cd $(DOTFILES_DIR) && \
	for dir in $(STOW_DIRS); do \
		if [ -d "$$dir" ]; then \
			echo "Stowing $$dir..."; \
			stow -d $(DOTFILES_DIR) -t $(HOME) --adopt $$dir || exit 1; \
		else \
			echo "Warning: Directory $$dir not found, skipping..."; \
		fi; \
	done
	@echo "=== Configuration stowing completed ==="

# Clean up installation artifacts
clean:
	@echo "=== Cleaning up ==="
	@if [ -d "$(DOTFILES_DIR)" ]; then \
		read -p "Remove dotfiles directory? [y/N] " confirm && [ "$$confirm" = "y" ] && rm -rf $(DOTFILES_DIR); \
	fi
	@if [ -d "/tmp/yay" ]; then \
		rm -rf /tmp/yay; \
	fi
	@echo "=== Cleanup completed ==="

# Display help information
help:
	@echo "Arch Linux Post-Installation Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  all              - Run complete installation process"
	@echo "  clone-dotfiles   - Clone dotfiles repository"
	@echo "  install-packages - Install packages from dotfiles"
	@echo "  setup-nvim       - Setup Neovim configuration"
	@echo "  install-ohmyzsh  - Install Oh My Zsh"
	@echo "  setup-ohmyzsh-plugins - Setup Oh My Zsh plugins, themes, and fzf"
	@echo "  change-shell     - Change default shell to zsh"
	@echo "  stow-configs     - Stow configuration files"
	@echo "  clean            - Clean up installation artifacts"
	@echo "  help             - Display this help message"
	@echo ""
	@echo "Usage:"
	@echo "  make all                    # Complete installation"
	@echo "  make install-packages       # Install packages only"
	@echo "  make setup-ohmyzsh-plugins # Setup Oh My Zsh plugins, themes, and fzf only"
	@echo "  make stow-configs           # Stow configurations only"
