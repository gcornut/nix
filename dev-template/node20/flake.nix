{
  description = "A Nix-flake-based Node.js development environment";

  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs";
    # rev picked from https://www.nixhub.io/packages/nodejs
    node.url = "github:NixOS/nixpkgs?rev=83e677f31c84212343f4cc553bab85c2efcad60a";
  };

  outputs = inputs: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
    forEachSupportedSystem = f:
      inputs.node.lib.genAttrs supportedSystems (system:
        f {
          pkgs = import inputs.node {
            inherit system;
            overlays = [inputs.self.overlays.default];
          };
          node = import inputs.node {
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
      node,
    }: {
      default = pkgs.mkShell {
        packages = [node.nodejs node.yarn];
        DIRENV_NODE_BIN = ''${node.nodejs}/bin'';
        DIRENV_YARN_BIN = ''${node.yarn}/bin'';
      };
    });
  };
}
