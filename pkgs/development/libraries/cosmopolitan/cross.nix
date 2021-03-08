{ pkgs }:
let
  crossPkgs = import pkgs.path {
    localSystem = { inherit (pkgs.hostPlatform) config; };
    crossSystem = "x86_64-linux";
  };
in
crossPkgs.callPackage ./native.nix { }
