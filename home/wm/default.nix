{
  lib,
  mkDotfileLink,
  config,
  ...
}: {
  home.file = lib.mkMerge [
    {
      ".Brewfile".text = ''
        cask "nikitabobko/tap/aerospace"
        cask "mediosz/tap/swipeaerospace"
      '';
    }
    # Config
    (mkDotfileLink config {
      from = ./aerospace.toml;
      to = ".aerospace.toml";
    })
  ];
}
