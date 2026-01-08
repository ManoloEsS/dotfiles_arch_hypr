# ~/.zprofile
# Zsh profile for TTY autostart of Hyprland
# This file runs once at login (not for every shell like .zshrc)

# Intelligent Hyprland TTY autostart
# Only starts on primary TTYs, skips SSH, and includes safety checks
hyprland_autostart() {
    # Skip if already in a Wayland session
    [[ -n "$WAYLAND_DISPLAY" ]] && return
    
    # Skip if running in SSH session
    [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" || -n "$SSH_CONNECTION" ]] && return
    
    # Only autostart on TTY1-3 (primary login terminals)
    [[ "$XDG_VTNR" -gt 3 ]] && return
    
    # Check if Hyprland is installed
    if ! command -v Hyprland >/dev/null 2>&1; then
        echo "⚠️  Hyprland not found. Skipping autostart."
        return
    fi
    
    # Check if Hyprland config exists
    if [[ ! -f "$HOME/.config/hypr/hyprland.conf" ]]; then
        echo "⚠️  Hyprland config not found. Skipping autostart."
        return
    fi
    
    # Check for explicit disable flag
    [[ "$NO_AUTOSTART" == "1" ]] && return
    
    # All checks passed - start Hyprland
    echo "🚀 Starting Hyprland on TTY$XDG_VTNR..."
    exec Hyprland
}

# Run autostart function
hyprland_autostart

# Standard PATH and environment setup
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Set XDG base directories if not already set
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Default editor
export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-nvim}"

# GPG TTY for GPG operations if available
if command -v gpg >/dev/null 2>&1; then
    export GPG_TTY=$(tty)
fi