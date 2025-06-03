{
  pkgs,
  mkBrewfile,
  mkLaunchApp,
  ...
}: {
  # Packages
  home.packages = with pkgs; [
    # dev env
    nixd
    alejandra
    google-cloud-sdk
    tldr

    # JS
    pnpm
    yarn
    nodejs
    bun

    # media
    ffmpeg
    imagemagick

    # sync & network
    rsync
    rclone
  ];

  # Desktop apps
  home.file = mkBrewfile ''
    # media
    cask "spotify"
    cask "vlc"
    cask "losslesscut"
    cask "gimp"

    # browser
    cask "arc"
    cask "google-chrome"
    cask "firefox"
    cask "tor-browser"
    cask "zen"

    # sync & network
    cask "tailscale"
    cask "parsec"
    cask "syncthing"

    # messaging
    cask "slack"
    cask "signal"
    cask "discord"

    # dev
    cask "docker"
    cask "bitwarden"
  '';

  launchd.agents = mkLaunchApp "syncthing" "/Applications/Syncthing.app";
}
