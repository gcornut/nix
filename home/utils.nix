{
  self,
  lib,
  globals,
}:
with lib;
with builtins; rec {
  inherit globals;

  env = import (toAbsolutePath ../.env.nix);

  toAbsolutePath = path: let
    rootStr = toString self;
    pathStr = toString path;
  in
    assert assertMsg (hasPrefix rootStr pathStr)
    "${pathStr} does not start with ${rootStr}";
      (builtins.getEnv "PWD") + (removePrefix rootStr pathStr);

  mkDotfileLink = config: {
    from,
    to,
  }: {
    "${to}".source = config.lib.file.mkOutOfStoreSymlink (toAbsolutePath from);
  };

  mkDotdirLinks = config: {
    from,
    to,
  }: (pipe from [
    readDir
    (mapAttrsToList (
      name: type:
        if type == "directory"
        then
          (mkDotdirLinks config {
            from = from + "/${name}";
            to = "${to}/${name}";
          })
        else
          mkDotfileLink config {
            from = from + "/${name}";
            to = "${to}/${name}";
          }
    ))
    flatten
    mkMerge
  ]);

  mkBrewfile = text: {".Brewfile".text = text;};
}
