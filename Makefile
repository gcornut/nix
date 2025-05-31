# Setup: Install nix with installer: https://determinate.systems/posts/graphical-nix-installer
include .env
export $(shell sed 's/=.*//' .env)

init:
	nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake . --impure

switch:
	darwin-rebuild switch --flake . --impure

update:
	brew update & nix flake update & wait
	make switch & brew upgrade & wait
