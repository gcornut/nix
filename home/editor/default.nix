{ pkgs, config, mkDotfileLink, mkCaskList, ... }: {
  # Packages
  home.packages = with pkgs; [
    vim
    neovim
  ];

  # Desktop apps
  home.file.".Brewfile" = {
    text = mkCaskList [
      "zed"
      "visual-studio-code"
      "webstorm"
      "pycharm-ce"
    ];
  };

  home.file.".config/zed/settings.json".source = mkDotfileLink config ./zed/settings.json;
  home.file.".config/zed/keymap.json".source = mkDotfileLink config ./zed/keymap.json;
}
