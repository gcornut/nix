{
  lib,
  mkDotfileLink,
  mkBrewfile,
  config,
  ...
}: {
  home.file = lib.mkMerge [
    (mkBrewfile ''
      # aerospace
      cask "nikitabobko/tap/aerospace"
      cask "mediosz/tap/swipeaerospace"
    '')
    # Config
    (mkDotfileLink config {
      from = ./aerospace.toml;
      to = ".aerospace.toml";
    })
  ];
}
