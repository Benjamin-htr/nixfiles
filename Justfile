default:
  @just --list

check:
  nix flake check --all-systems --no-build

build-mac:
  nix build .#darwinConfigurations.macbook-benjamin.system

switch-mac:
  sudo darwin-rebuild switch --flake .#macbook-benjamin

build-homelab:
  nix build .#nixosConfigurations.homelab.config.system.build.toplevel

switch-homelab:
  sudo nixos-rebuild switch --flake .#homelab

update:
  nix flake update

format:
  nix fmt -- $(git ls-files '*.nix')
