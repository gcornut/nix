{ self, lib }:
{
  mkDotfileLink = config: path:
    let
      rootStr = toString self;
      pathStr = toString path;
    in assert lib.assertMsg (lib.hasPrefix rootStr pathStr)
      "${pathStr} does not start with ${rootStr}";
      config.lib.file.mkOutOfStoreSymlink (builtins.getEnv "PWD") + (lib.removePrefix rootStr pathStr);
  getEnv = var:
    let
      val = builtins.getEnv var;
    in
      assert lib.assertMsg (val != "") "Missing env var ${var}";
      val;
}
