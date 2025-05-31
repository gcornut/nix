{lib, ...}:
with lib;
with builtins; {
  programs.home-manager.enable = true;
  home.stateVersion = "24.05";

  imports = pipe ./. [
    readDir
    (filterAttrs (_name: type: type == "directory"))
    attrNames
    (map (dirName: (import ./${dirName})))
  ];

  home.file.".Brewfile".onChange = ''
    /opt/homebrew/bin/brew bundle install --cleanup --no-upgrade --force --global
  '';
}
