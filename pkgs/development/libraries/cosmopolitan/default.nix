{ callPackage, stdenv }:
callPackage (if stdenv.isLinux && stdenv.isx86_64 then ./native.nix else ./cross.nix) { }
