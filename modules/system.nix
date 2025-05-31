{pkgs, ...}: {
  #  macOS's System configuration
  #    https://nix-darwin.github.io/nix-darwin/manual/index.html

  environment.systemPackages = with pkgs; [coreutils];

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
}
