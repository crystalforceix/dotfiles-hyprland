{
  description = "Hyprland dotfiles with Quickshell";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = { self, nixpkgs, home-manager, hyprland, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations = {
        # Replace "yourUsername" with your actual username
        yourUsername = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = [
            hyprland.homeManagerModules.default
            {
              home = {
                username = "yourUsername";
                homeDirectory = "/home/yourUsername";
                stateVersion = "24.05";

                packages = with pkgs; [
                  # Hyprland ecosystem
                  hyprland
                  hyprpaper
                  xdg-desktop-portal-hyprland

                  # Terminal & Shell
                  kitty

                  # Media & Audio
                  playerctl
                  cava
                  mpv

                  # System utilities
                  brightnessctl
                  swaybg
                  wl-clipboard
                  jq
                  sysstat
                  procps

                  # File manager
                  xfce.thunar
                  xfce.thunar-archive-plugin

                  # Screenshot tools
                  grim
                  slurp

                  # Notifications
                  dunst

                  # Fonts
                  noto-fonts-cjk
                  (nerdfonts.override { fonts = [ "ComicShannsMono" ]; })

                  # Icons
                  papirus-icon-theme

                  # Multimedia
                  ffmpeg
                  kdialog
                  xdg-user-dirs

                  # Additional tools
                  git
                ];

                # Symlink dotfiles
                file = {
                  ".config/hypr" = {
                    source = ./.config/hypr;
                    recursive = true;
                  };
                  ".config/kitty" = {
                    source = ./.config/kitty;
                    recursive = true;
                  };
                  ".config/dunst" = {
                    source = ./.config/dunst;
                    recursive = true;
                  };
                  ".config/quickshell" = {
                    source = ./.config/quickshell;
                    recursive = true;
                  };
                  "Pictures" = {
                    source = ./Pictures;
                    recursive = true;
                  };
                };

                sessionVariables = {
                  EDITOR = "vim";
                  NIXOS_OZONE_WL = "1"; # Enable Wayland for Electron apps
                };
              };

              # Wayland session variables
              wayland.windowManager.hyprland = {
                enable = true;
                package = hyprland.packages.${pkgs.system}.hyprland;
                xwayland.enable = true;
                systemd.enable = true;
              };

              # Programs configuration
              programs = {
                home-manager.enable = true;

                kitty = {
                  enable = true;
                };

                git = {
                  enable = true;
                };
              };

              # Services
              services = {
                dunst.enable = true;
              };

              # XDG configuration
              xdg = {
                enable = true;
                userDirs = {
                  enable = true;
                  createDirectories = true;
                };
              };
            }
          ];
        };
      };

      # NixOS configuration module
      nixosModules.default = { config, pkgs, ... }: {
        # Enable Hyprland
        programs.hyprland = {
          enable = true;
          package = hyprland.packages.${pkgs.system}.hyprland;
        };

        # XDG Portal
        xdg.portal = {
          enable = true;
          extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
        };

        # Enable polkit
        security.polkit.enable = true;

        # Fonts
        fonts.packages = with pkgs; [
          noto-fonts-cjk
          (nerdfonts.override { fonts = [ "ComicShannsMono" ]; })
        ];

        # Sound
        sound.enable = true;
        hardware.pulseaudio.enable = false;
        security.rtkit.enable = true;
        services.pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
        };
      };
    };
}
