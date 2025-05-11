{ pkgs, mkCaskList, ... }: {
  # Packages
  home.packages = with pkgs; [
    # dev env
    nixd
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
  home.file.".Brewfile" = {
    text = mkCaskList [
      # media
      "spotify"
      "vlc"
      "losslesscut"

      # browser
      "arc"
      "google-chrome"
      "firefox"
      "tor-browser"

      # sync & network
      "tailscale"
      "parsec"
      "syncthing"

      # messaging
      "slack"
      "signal"
      "discord"

      # dev
      "docker"
      "bitwarden"
    ];
  };
}
