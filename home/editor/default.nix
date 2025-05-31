{
  pkgs,
  config,
  mkDotfileLinks,
  mkCaskList,
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
    {
      ".Brewfile".text = mkCaskList [
        "zed"
        "visual-studio-code"
        "webstorm"
        "pycharm-ce"
      ];
    }
    # Config
    (mkDotfileLinks config {
      from = ./zed;
      to = ".config/zed";
    })
  ];
}
