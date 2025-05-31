{pkgs, ...}: let
  utils = import ./utils {inherit pkgs;};
in {
  services.macos-remap-keys = {
    enable = true;
    keyboard = {
      Capslock = "Escape";
    };
  };

  launchd.agents.keyboard-monitor = {
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
