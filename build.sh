#!/usr/bin/env bash
set -e

nix-instantiate --show-trace '<nixos-21.11/nixos>' -A system -I nixos-config=kurisu/configuration.nix
nix-instantiate --show-trace '<nixos-21.11/nixos>' -A system -I nixos-config=dionysus/configuration.nix

nix-instantiate --show-trace '<nixpkgs/nixos>' -A system -I nixos-config=aqua/configuration.nix

nix-instantiate --show-trace '<nixpkgs/nixos>' -A system --argstr system aarch64-linux -I nixos-config=ananke/configuration.nix
nix-instantiate --show-trace '<nixpkgs/nixos>' -A system --argstr system aarch64-linux -I nixos-config=hades/configuration.nix
