{
  description = "A Nix-flake-based Node.js development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    # rev picked from https://www.nixhub.io/packages/nodejs
    node16.url = "github:NixOS/nixpkgs?rev=6c6409e965a6c883677be7b9d87a95fab6c3472e";
  };

  outputs = inputs: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
    forEachSupportedSystem = f:
      inputs.nixpkgs.lib.genAttrs supportedSystems (system:
        f {
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [inputs.self.overlays.default];
          };
          node16 = import inputs.node16 {
            inherit system;
            overlays = [inputs.self.overlays.default];
          };
        });
  in {
    overlays.default = final: prev: rec {
      nodejs = prev.nodejs;
      yarn = prev.yarn.override {inherit nodejs;};
    };

    devShells = forEachSupportedSystem ({
      pkgs,
      node16,
    }: {
      default = pkgs.mkShell {
        packages = [node16.nodejs node16.yarn];
        DIRENV_NODE_BIN = ''${node16.nodejs}/bin'';
        DIRENV_YARN_BIN = ''${node16.yarn}/bin'';
      };
    });
  };
}
