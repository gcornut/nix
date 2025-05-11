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
    hostname = "218300486L";
    system = "aarch64-darwin";
    user = "gcornut";
    home = "/Users/${user}";
    configuration = {lib, ...}: {
      nix = {
        enable = false; # nix is managed by nix determinate
        nixPath = ["nixpkgs=${nixpkgs}"];
      };
      nixpkgs = {
        hostPlatform = system;
        config = {allowUnfree = true;};
      };
      users.users."${user}" = {home = home;};
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = false;
        users."${user}" = import ./home;
        extraSpecialArgs = import ./modules/utils.nix {inherit self lib;};
      };
    };
  in {
    darwinConfigurations."${hostname}" = nix-darwin.lib.darwinSystem {
      modules = [
        ./modules/system.nix
        configuration
        home-manager.darwinModules.home-manager
      ];
    };
    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
  };
}
