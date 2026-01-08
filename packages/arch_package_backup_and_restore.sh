#!/bin/bash
set -euo pipefail

PKGLIST="pkglist.txt"
AURLIST="aurlist.txt"

# Hardware-specific packages to skip
SKIP_PKGS=(
  # Kernels
  "linux" "linux-lts" "linux-zen" "linux-hardened"
  "virtualbox-host-modules-arch"

  # Firmware
  "linux-firmware"

  # NVIDIA
  "nvidia" "nvidia-dkms" "nvidia-utils" "nvidia-settings" "nvidia-lts"

  # AMD
  "xf86-video-amdgpu" "vulkan-radeon"

  # Intel
  "xf86-video-intel" "vulkan-intel"

  # Other GPUs
  "xf86-video-nouveau"

  # Microcode
  "intel-ucode" "amd-ucode"

  # Bootloaders
  "grub" "systemd-boot-pacman-hook" "refind" "lilo"

  # AUR helpers (we only keep yay)
  "paru" "paru-debug"
)

backup() {
    echo "📦 Backing up package lists..."

    # Explicitly installed packages (repo + AUR)
    pacman -Qqe > "$PKGLIST".all

    # Installed AUR packages
    pacman -Qm > "$AURLIST".all

    # Filter base + base-devel packages
    BASE_PKGS=$(comm -12 <(pacman -Qq | sort) <(pacman -Sgq base base-devel | sort))

    # Filter repo packages: remove base, skip list, AUR, and *-debug
    grep -vxFf <(printf "%s\n" $BASE_PKGS "${SKIP_PKGS[@]}") "$PKGLIST".all \
      | grep -vxFf <(pacman -Qm | awk '{print $1}') \
      | grep -v -- '-debug$' \
      > "$PKGLIST"

    # Filter AUR packages: remove helpers and *-debug
    awk '{print $1}' "$AURLIST".all \
      | grep -v -- '-debug$' \
      | grep -vE '^(paru|yay-debug)$' \
      > "$AURLIST"

    # Find skipped ones
    comm -12 <(sort "$PKGLIST".all) <(printf "%s\n" $BASE_PKGS "${SKIP_PKGS[@]}" | sort -u) > skipped.txt

    rm "$PKGLIST".all "$AURLIST".all

    echo "✅ Package lists saved:"
    echo "  - $(wc -l < "$PKGLIST") pacman packages (repo only) → $PKGLIST"
    echo "  - $(wc -l < "$AURLIST") AUR packages                → $AURLIST"

    if [[ -s skipped.txt ]]; then
        echo "⚠️  Skipped packages:"
        cat skipped.txt
    else
        echo "✅ No packages skipped."
        rm skipped.txt
    fi
}

restore() {
    local dryrun="${1:-}"

    if [[ "$dryrun" == "--dry-run" ]]; then
        echo "🔍 Dry run: packages that would be installed"
    else
        echo "🔄 Restoring packages..."
        echo "📡 Updating package databases..."
        sudo pacman -Syu --noconfirm || {
            echo "❌ Failed to update package databases"
            return 1
        }
        
        echo "🔧 Installing essential build tools..."
        sudo pacman -S --needed --noconfirm base-devel git || {
            echo "❌ Failed to install base development tools"
            return 1
        }
    fi

    if [[ -f "$PKGLIST" ]]; then
        echo "📥 Pacman packages:"
        # Clean up package list first
        sed '/^[[:space:]]*$/d' "$PKGLIST" > "${PKGLIST}.clean"
        
        if [[ "$dryrun" == "--dry-run" ]]; then
            echo "Packages that would be installed:"
            cat "${PKGLIST}.clean" || true
        else
            if [[ -s "${PKGLIST}.clean" ]]; then
                echo "Installing $(wc -l < "${PKGLIST}.clean") packages..."
                sudo pacman -S --needed $(cat "${PKGLIST}.clean") || {
                    echo "❌ Some pacman packages failed to install"
                    return 1
                }
            else
                echo "⚠️ No valid packages found in $PKGLIST"
            fi
        fi
        rm -f "${PKGLIST}.clean"
    fi

    if ! command -v yay &>/dev/null; then
        if [[ "$dryrun" == "--dry-run" ]]; then
            echo "📥 Would install yay (AUR helper)"
        else
            echo "📥 Installing yay (AUR helper)..."
            tmpdir=$(mktemp -d)
            if git clone https://aur.archlinux.org/yay.git "$tmpdir" 2>/dev/null; then
                (cd "$tmpdir" && makepkg -si --noconfirm) || {
                    echo "❌ Failed to build and install yay"
                    rm -rf "$tmpdir"
                    return 1
                }
                rm -rf "$tmpdir"
                echo "✅ yay installed successfully"
            else
                echo "❌ Failed to clone yay repository"
                rm -rf "$tmpdir"
                return 1
            fi
        fi
    fi

    if [[ -f "$AURLIST" ]]; then
        echo "📥 AUR packages:"
        # Clean up AUR list first
        sed '/^[[:space:]]*$/d' "$AURLIST" > "${AURLIST}.clean"
        
        if [[ "$dryrun" == "--dry-run" ]]; then
            echo "AUR packages that would be installed:"
            cat "${AURLIST}.clean" || true
        else
            if [[ -s "${AURLIST}.clean" ]]; then
                echo "Installing $(wc -l < "${AURLIST}.clean") AUR packages..."
                yay -S --needed $(cat "${AURLIST}.clean") || {
                    echo "❌ Some AUR packages failed to install"
                    echo "💡 You may want to install them individually:"
                    cat "${AURLIST}.clean" | sed 's/^/  /'
                }
            else
                echo "⚠️ No valid AUR packages found in $AURLIST"
            fi
        fi
        rm -f "${AURLIST}.clean"
    fi

    if [[ "$dryrun" == "--dry-run" ]]; then
        echo "✅ Dry run complete (no changes made)"
    else
        echo "✅ Restore complete!"
    fi
}

case "${1:-}" in
    backup) backup ;;
    restore) restore ;;
    restore-dry) restore --dry-run ;;
    *)
        echo "Usage: $0 {backup|restore|restore-dry}"
        exit 1
        ;;
esac

