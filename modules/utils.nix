{ self, lib }: with lib;
{
  mkDotfileLink = config: path:
    let
      rootStr = toString self;
      pathStr = toString path;
    in assert assertMsg (hasPrefix rootStr pathStr)
      "${pathStr} does not start with ${rootStr}";
      config.lib.file.mkOutOfStoreSymlink (builtins.getEnv "PWD") + (removePrefix rootStr pathStr);
  getEnv = var:
    let
      val = builtins.getEnv var;
    in
      assert assertMsg (val != "") "Missing env var ${var}";
      val;
  mkCaskList = concatMapStrings (cask: "cask \"${cask}\"\n");
}
