# flake.nix
{
  description = "Jacco's nix-darwin configs";

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
  };

  outputs = {
    self,
    nixpkgs,
    darwin,
    home-manager,
    nix-homebrew,
    ...
  }: let
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
  };
}
