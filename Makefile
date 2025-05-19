# Setup: Install nix with installer: https://determinate.systems/posts/graphical-nix-installer

init:
	sudo nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake . --impure

brew-install:
	brew bundle install --cleanup --no-upgrade --force --global

switch:
	sudo darwin-rebuild switch --flake . --impure

update:
	brew update & sudo nix flake update & wait
	make switch & brew upgrade & wait
