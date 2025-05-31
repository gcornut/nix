{
  description = "nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nix-darwin,
    nixpkgs,
    home-manager,
    ...
  }: let
    globals = rec {
      hostname = "218300486L";
      system = "aarch64-darwin";
      user = "gcornut";
      home = "/Users/${user}";
    };
    configuration = {lib, ...}: {
      nix = {
        enable = false; # nix is managed by nix determinate
        nixPath = ["nixpkgs=${nixpkgs}"];
      };
      nixpkgs = {
        hostPlatform = globals.system;
        config = {allowUnfree = true;};
      };
      users.users."${globals.user}" = {home = globals.home;};
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = false;
        users."${globals.user}" = import ./home;
        extraSpecialArgs = import ./modules/utils.nix {inherit self lib globals;};
      };
      system.primaryUser = globals.user;
    };
  in {
    darwinConfigurations."${globals.hostname}" = nix-darwin.lib.darwinSystem {
      modules = [
        ./modules/system.nix
        configuration
        home-manager.darwinModules.home-manager
      ];
    };
    formatter.${globals.system} = nixpkgs.legacyPackages.${globals.system}.alejandra;
  };
}
