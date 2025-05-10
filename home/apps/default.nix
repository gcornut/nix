{ pkgs, ... }: {
  home.packages = with pkgs; [
    # browser
    arc-browser
    google-chrome
    firefox

    # dev env
    docker
    nixd
    google-cloud-sdk

    # JS
    pnpm
    yarn
    nodejs
    bun

    # media
    spotify
    ffmpeg
    imagemagick
    losslesscut-bin

    # sync & network
    rsync
    rclone
    tailscale

    # messaging
    slack
    signal-desktop-bin
    discord

    # pass
    bitwarden-desktop
  ];
}
