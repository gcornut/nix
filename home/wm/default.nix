{
  lib,
  mkDotdirLinks,
  mkBrewfile,
  mkLaunchApp,
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
    (mkDotdirLinks config {
      from = ./aerospace;
      to = ".config/aerospace";
    })
  ];
  launchd.agents = lib.mkMerge [
    (mkLaunchApp "hyperkey" "/Applications/AeroSpace.app")
  ];
}
