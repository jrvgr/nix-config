# flake.nix
{
  description = "Jacco's nix-darwin and NixOS configs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Asahi hardware support module (NixBook, NixOS on Apple Silicon)
    apple-silicon = {
      url = "github:tpwrules/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-aarch64-widevine = {
      url = "github:epetousis/nixos-aarch64-widevine";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Advisory: lets `nix flake check`/`nix develop` etc. offer this substituter
  # even before a host's own nix.settings (modules/shared.nix, modules/nixos/nix.nix)
  # has been activated.
  nixConfig = {
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs = {
    self,
    nixpkgs,
    darwin,
    home-manager,
    nix-homebrew,
    apple-silicon,
    nixos-aarch64-widevine,
    ...
  } @ inputs: let
    mkDarwin = {
      hostname,
      system,
      user,
      extraModules ? [],
      extraHomeModules ? [],
    }:
      darwin.lib.darwinSystem {
        inherit system;
        specialArgs = {inherit hostname user system;};
        modules =
          [
            ./hosts/darwin/shared.nix
            ./modules/darwin/system.nix
            ./modules/darwin/homebrew/default.nix
            ./modules/darwin/apps/ghostty.nix
            ./modules/darwin/apps/vscode.nix
            ./modules/shared.nix

            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                enable = true;
                user = user;
                autoMigrate = true;
              };
            }

            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.verbose = false;
              home-manager.extraSpecialArgs = {inherit hostname user;};
              home-manager.backupFileExtension = "back";
              home-manager.users.${user} = {
                imports =
                  [
                    ./home/shared
                  ]
                  ++ extraHomeModules;
              };
            }
          ]
          ++ extraModules;
      };

    # NixOS analogue of mkDarwin, above -- same shape, no homebrew/shared
    # macOS home (home/shared is Karabiner/Hammerspoon, Darwin-only) and no
    # `hosts/nixos/shared.nix` yet since there's currently only one NixOS
    # host; split that out the way hosts/darwin/shared.nix does if a second
    # one shows up.
    mkNixos = {
      hostname,
      system,
      user,
      extraModules ? [],
      extraHomeModules ? [],
    }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit hostname user system inputs;};
        modules =
          [
            ./modules/nixos/boot.nix
            ./modules/nixos/desktop.nix
            ./modules/nixos/networking.nix
            ./modules/nixos/nix.nix
            ./modules/nixos/nix-ld.nix
            ./modules/nixos/users.nix
            ./modules/nixos/asahi-kernel-cache.nix

            apple-silicon.nixosModules.apple-silicon-support

            { nixpkgs.overlays = [ nixos-aarch64-widevine.overlays.default ]; }

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {inherit hostname user inputs;};
              home-manager.users.${user} = {
                imports = extraHomeModules;
              };
            }
          ]
          ++ extraModules;
      };
  in {
    darwinConfigurations = {
      "darwin-personal" = mkDarwin {
        hostname = "MekBroekBro";
        system = "aarch64-darwin";
        user = "jacco";
        extraModules = [
          ./hosts/darwin/personal
          ./modules/darwin/homebrew/personal.nix
        ];
        extraHomeModules = [
          ./home/personal
        ];
      };

      "darwin-work" = mkDarwin {
        hostname = "MacHarborn";
        system = "aarch64-darwin";
        user = "jacco";
        extraModules = [
          ./hosts/darwin/work
          ./modules/darwin/homebrew/work.nix
        ];
        extraHomeModules = [
          ./home/work
        ];
      };
    };

    nixosConfigurations = {
      "nixbook" = mkNixos {
        hostname = "NixBook";
        system = "aarch64-linux";
        user = "jacco";
        extraModules = [
          ./hosts/nixos/nixbook
        ];
        extraHomeModules = [
          ./home/nixbook
        ];
      };
    };
  };
}
