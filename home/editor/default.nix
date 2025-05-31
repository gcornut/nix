{ pkgs, config, mkDotfileLink, ... }: {
  home.packages = [
    pkgs.vim
    pkgs.neovim
    pkgs.zed-editor
    pkgs.vscode
  ];

  home.file.".config/zed/settings.json".source = mkDotfileLink config ./zed/settings.json;
  home.file.".config/zed/keymap.json".source = mkDotfileLink config ./zed/keymap.json;
}
