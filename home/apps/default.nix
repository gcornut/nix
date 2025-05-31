{
  pkgs,
  mkBrewfile,
  ...
}: {
  # Packages
  home.packages = with pkgs; [
    # dev env
    nixd
    alejandra
    google-cloud-sdk

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

    # browser
    cask "arc"
    cask "google-chrome"
    cask "firefox"
    cask "tor-browser"

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
}
