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
  mkDotfileLinks = config: {
    from,
    to,
  }: (pipe from [
    readDir
    (mapAttrsToList (
      name: type:
        if type == "directory"
        then
          (mkDotfileLinks config {
            from = from + ("/" + name);
            to = to + "/" + name;
          })
        else
          mkDotfileLink config {
            to = "${to}/${name}";
            from = from + ("/" + name);
          }
    ))
    flatten
    mkMerge
  ]);
  mkCaskList = concatMapStrings (cask: "cask \"${cask}\"\n");
}
