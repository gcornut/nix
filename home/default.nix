{ lib, ... }:
{
  programs.home-manager.enable = true;
  home.stateVersion = "24.05";

  imports = lib.pipe ./. [
    builtins.readDir
    (lib.filterAttrs (_name: type: type == "directory"))
    builtins.attrNames
    (lib.map (dirName: (import ./${dirName})))
  ];
}
