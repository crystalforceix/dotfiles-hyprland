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

      # Helper function to create config for any user
      mkHomeConfiguration = username: home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          hyprland.homeManagerModules.default
          {
            home = {
              inherit username;
              homeDirectory = "/home/${username}";
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
                  libsForQt5.kdialog
                  xdg-user-dirs

                  # Additional tools
                  git
                ];

                # Symlink dotfiles (only if directories exist)
                file =
                  let
                    linkIfExists = path: target:
                      if builtins.pathExists path
                      then { ${target} = { source = path; recursive = true; }; }
                      else {};
                  in
                  (linkIfExists ./.config/hypr ".config/hypr") //
                  (linkIfExists ./.config/kitty ".config/kitty") //
                  (linkIfExists ./.config/dunst ".config/dunst") //
                  (linkIfExists ./.config/quickshell ".config/quickshell") //
                  (linkIfExists ./Pictures "Pictures");

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
    in
    {
      # Create homeConfigurations for common usernames
      # Users can use any of these or specify their own
      homeConfigurations = {
        # Example configurations - replace with your username
        long = mkHomeConfiguration "long";
        yourUsername = mkHomeConfiguration "yourUsername";
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
