{
  pkgs,
  config,
  mkDotdirLinks,
  mkBrewfile,
  lib,
  ...
}: {
  # Packages
  home.packages = with pkgs; [
    vim
    neovim
  ];

  home.file = lib.mkMerge [
    # Desktop apps
    (mkBrewfile ''
      # editor
      cask "zed"
      cask "visual-studio-code"
      cask "webstorm"
      cask "pycharm-ce"
      cask "cursor"
    '')
    # Config
    (mkDotdirLinks config {
      from = ./zed;
      to = ".config/zed";
    })
  ];
}
