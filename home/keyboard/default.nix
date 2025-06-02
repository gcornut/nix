{
  pkgs,
  lib,
  mkBrewfile,
  mkLaunchApp,
  ...
}: let
  utils = import ./utils {inherit pkgs;};
in {
  # Install
  home.file = mkBrewfile ''
    # hyperkey
    cask "hyperkey"
  '';

  # Import Hyperkey config
  home.activation = {
    setupHyperKey = lib.hm.dag.entryAfter ["writeBoundary"] ''
      /usr/bin/defaults import com.knollsoft.Hyperkey ${./hyperkey/com.knollsoft.Hyperkey.plist}
    '';
  };

  # Run at login
  launchd.agents = lib.mkMerge [
    (mkLaunchApp "hyperkey" "/Applications/Hyperkey.app")
    {
      keyboard-monitor = {
        enable = true;
        config = {
          ProgramArguments = [
            "${utils}/usb-monitor"
            "--productId"
            "50501"
            "--on-connect"
            "${utils}/switch-layout set French-PC"
            "--on-disconnect"
            "${utils}/switch-layout set French"
          ];
          KeepAlive = true;
          RunAtLoad = true;
          ProcessType = "Background";
        };
      };
    }
  ];
}
