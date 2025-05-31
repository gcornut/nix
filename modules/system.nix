{pkgs, ...}: {
  #  macOS's System configuration
  #    https://nix-darwin.github.io/nix-darwin/manual/index.html

  system = {
    stateVersion = 6;

    defaults = {
      menuExtraClock.Show24Hour = true;
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        _HIHideMenuBar = false;
        AppleShowAllExtensions = true;
        NSTableViewDefaultSizeMode = 2;
        NSDocumentSaveNewDocumentsToCloud = false;
        ApplePressAndHoldEnabled = false;
      };
      LaunchServices.LSQuarantine = false;
      finder = {
        ShowPathbar = true;
        ShowStatusBar = true;
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "clmv";
        _FXSortFoldersFirst = true;
      };
      spaces.spans-displays = true;
      dock = {
        autohide = true;
        mineffect = "scale";
        mru-spaces = false;
        show-recents = false;
        tilesize = 65;
        wvous-br-corner = 14;
      };
      WindowManager = {
        EnableStandardClickToShowDesktop = false;
        AppWindowGroupingBehavior = true;
        StandardHideDesktopIcons = true;
        HideDesktop = true;
      };
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
  };

  security = {
    # Add ability to used TouchID for sudo authentication
    pam.services.sudo_local.touchIdAuth = true;
  };
}
