# NixOS Installation Guide

Quick guide to install these dotfiles on NixOS or any system with Nix.

## Prerequisites

Enable Nix Flakes:

```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

## Installation

### 1. Clone the repository

```bash
cd ~
git clone https://github.com/mailong2401/dotfiles-hyprland
cd dotfiles-hyprland
```

### 2. Install with Home Manager

**If your username is in flake.nix** (currently: `long`, `yourUsername`):

```bash
# Replace "long" with your actual username
nix run home-manager/master -- switch --flake .#long
```

**If your username is NOT in flake.nix**:

Edit [flake.nix](flake.nix) and add your username:

```nix
homeConfigurations = {
  long = mkHomeConfiguration "long";
  yourUsername = mkHomeConfiguration "yourUsername";
  alice = mkHomeConfiguration "alice";  # Add this line with your username
};
```

Then run:

```bash
nix run home-manager/master -- switch --flake .#alice
```

### 3. Manual setup for Quickshell

Quickshell is not in nixpkgs yet, clone it manually:

```bash
mkdir -p ~/.config/quickshell
git clone https://github.com/mailong2401/cartoon-shell.git ~/.config/quickshell/cartoon-shell
```

## What Gets Installed

The flake will:
- Install all packages from the Arch setup (hyprland, kitty, dunst, etc.)
- Symlink config files from `.config/` to your home directory
- Set up Hyprland with proper Wayland support
- Install fonts and icon themes

## Updating

```bash
cd ~/dotfiles-hyprland
git pull
home-manager switch --flake .#yourUsername
```

## Troubleshooting

**"error: attribute 'long' missing"**
- You need to add your username to flake.nix or use an existing one

**Config files not found**
- Make sure `.config/hypr`, `.config/kitty` exist in the repo
- The flake will skip missing directories automatically

**Hyprland won't start**
- Check GPU drivers: `nix-shell -p hyprland --run "hyprland --version"`
- Check logs: `journalctl -xe`

## Differences from Arch

- **quickshell-git**: Not in nixpkgs, clone manually
- **mpvpaper**: May not be available, can be skipped
- **yay**: Not needed, everything is in nixpkgs or can be packaged

## For NixOS System-Wide

Add to `/etc/nixos/flake.nix`:

```nix
{
  inputs.dotfiles.url = "github:mailong2401/dotfiles-hyprland";

  outputs = { nixpkgs, dotfiles, ... }: {
    nixosConfigurations.yourHostname = nixpkgs.lib.nixosSystem {
      modules = [
        dotfiles.nixosModules.default
        # ... your other modules
      ];
    };
  };
}
```
