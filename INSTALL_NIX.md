# Installation Guide for NixOS/Nix

This guide explains how to use these dotfiles with NixOS or Home Manager.

## Prerequisites

- NixOS or any Linux distro with Nix package manager installed
- Flakes enabled in your Nix configuration

## Enable Flakes

Add to `/etc/nixos/configuration.nix` (NixOS) or `~/.config/nix/nix.conf` (standalone Nix):

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

Or in `~/.config/nix/nix.conf`:
```
experimental-features = nix-command flakes
```

## Installation

### Option 1: Home Manager (Recommended for dotfiles)

```bash
cd ~
git clone https://github.com/mailong2401/dotfiles-hyprland
cd dotfiles-hyprland

# Edit flake.nix and replace "yourUsername" with your actual username

# Apply the configuration
nix run home-manager/master -- switch --flake .#yourUsername
```

### Option 2: NixOS System-wide

Add to your `/etc/nixos/configuration.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland";
    dotfiles.url = "github:mailong2401/dotfiles-hyprland";
  };

  outputs = { self, nixpkgs, hyprland, dotfiles, ... }: {
    nixosConfigurations.yourHostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hardware-configuration.nix
        dotfiles.nixosModules.default
        {
          # Your other configurations
        }
      ];
    };
  };
}
```

Then rebuild:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#yourHostname
```

### Option 3: Standalone Home Manager

```bash
cd ~/dotfiles-hyprland

# Edit the flake.nix and update username

# Build and activate
home-manager switch --flake .#yourUsername
```

## Manual Configuration Steps

### 1. Clone Quickshell Configuration

```bash
mkdir -p ~/.config/quickshell
git clone https://github.com/mailong2401/cartoon-shell.git ~/.config/quickshell/cartoon-shell
```

### 2. Update XDG User Directories

```bash
xdg-user-dirs-update
```

## Configuration Files

The flake will automatically symlink these directories:
- `.config/hypr` - Hyprland configuration
- `.config/kitty` - Kitty terminal
- `.config/dunst` - Notification daemon
- `.config/quickshell` - Quickshell configuration
- `Pictures` - Wallpapers

## Installed Packages

All packages from the original setup.sh are included:

**Core packages:**
- hyprland, hyprpaper, xdg-desktop-portal-hyprland
- kitty, dunst, thunar
- playerctl, brightnessctl, swaybg
- wl-clipboard, grim, slurp
- jq, sysstat, procps
- mpv, ffmpeg, cava
- kdialog, xdg-user-dirs

**Fonts:**
- noto-fonts-cjk
- Comic Shanns Nerd Font

**Icons:**
- papirus-icon-theme

## Updating

```bash
cd ~/dotfiles-hyprland
git pull
home-manager switch --flake .#yourUsername
```

## Troubleshooting

### Flakes not enabled
```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### Hyprland won't start
Make sure you're using a compatible kernel and GPU drivers:
```bash
# Check if Hyprland is installed
nix-shell -p hyprland --run "hyprland --version"
```

### Fonts not showing
```bash
fc-cache -fv
```

## Uninstall

```bash
# Remove Home Manager generation
home-manager remove-generations old

# Or remove specific generation
home-manager generations
home-manager remove-generations <number>
```

## Notes

- This flake uses `nixos-unstable` channel for latest packages
- Hyprland is pulled from the official Hyprland flake
- Comic Shanns font might need to be adjusted in the font override
- Some AUR-specific packages (like quickshell-git) are not in nixpkgs yet

## Differences from Arch Setup

- **quickshell-git**: Not available in nixpkgs, need to clone manually or package it
- **mpvpaper**: May need to be built from source or use alternative
- All other packages have Nix equivalents

## Support

For NixOS/Nix specific issues, check:
- NixOS Wiki: https://nixos.wiki/
- Hyprland on NixOS: https://wiki.hyprland.org/Nix/
