{ pkgs, ... }:

  ###################################################################################
  #
  #  macOS's System configuration
  #
  #  All the configuration options are documented here:
  #    https://daiderd.com/nix-darwin/manual/index.html#sec-options
  #
  ###################################################################################
{
  environment.systemPackages = with pkgs; [ coreutils ];

  system = {
    stateVersion = 6;

    defaults = {
      menuExtraClock.Show24Hour = true;
    };
  };

  security = {
    # Add ability to used TouchID for sudo authentication
    pam.services.sudo_local.touchIdAuth = true;
  };

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      cleanup = "uninstall"; # uninstalls all formulae not listed here (use "zap" to remove related filed).
    };

    taps = ["homebrew/services"];

    brews = [];

    casks = [
      "vlc"
      "tor-browser"
      "parsec"
      "syncthing"
      "webstorm"
      "pycharm-ce"
      "docker"
    ];

    masApps = {
      "Numbers" = 409203825;
    };
  };
}
