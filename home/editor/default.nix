{ pkgs, config, mkDotfileLink, ... }: {
  home.packages = with pkgs; [
    vim
    neovim
    zed-editor
    vscode
  ];

  home.file.".config/zed/settings.json".source = mkDotfileLink config ./zed/settings.json;
  home.file.".config/zed/keymap.json".source = mkDotfileLink config ./zed/keymap.json;
}
