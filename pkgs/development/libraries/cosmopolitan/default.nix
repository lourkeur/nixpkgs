{ lib, gcc9Stdenv, makeWrapper, runCommand, cosmopolitan }:
gcc9Stdenv.mkDerivation {
  pname = "cosmopolitan-unstable";
  version = "20210228";
  src = builtins.fetchGit {
    url = "https://github.com/jart/cosmopolitan";
    rev = "94afa982c35d4322999b5591f6d41d5cfc3f19a5";
    ref = "master";
  };
  postPatch = ''
    sed -i -e "s|/usr/bin/env bash|/bin/sh|" build/findtmp
    rm -r third_party/gcc
  '';
  dontConfigure = true;
  dontFixup = true;
  nativeBuildInputs = [ makeWrapper ];
  enableParallelBuilding = true;
  preBuild = ''
    makeFlagsArray=(SHELL=/bin/sh AS=as CC=gcc GCC=gcc CXX=g++ LD=ld OBJCOPY=objcopy "MKDIR=mkdir -p")
  '';
  installPhase = ''
    runHook preInstall
    mkdir -p $out/{bin,lib/include}
    install o/cosmopolitan.h $out/lib/include
    install o/cosmopolitan.a o/libc/crt/crt.o o/ape/ape.{o,lds} $out/lib
    makeWrapper ${gcc9Stdenv.cc}/bin/gcc $out/bin/cosmoc --add-flags "-O -static -nostdlib -nostdinc -fno-pie -no-pie -mno-red-zone -fuse-ld=bfd -Wl,-T,$out/lib/ape.lds -include $out/lib/include/cosmopolitan.h $out/lib/{crt.o,ape.o,cosmopolitan.a}"
    runHook postInstall
  '';
  passthru.tests = {
    hello = runCommand "hello-world" { } ''
      printf 'main() { printf("hello world\\n"); }\n' >hello.c
      ${gcc9Stdenv.cc}/bin/gcc -g -O -static -nostdlib -nostdinc -fno-pie -no-pie -mno-red-zone -o hello.com.dbg hello.c \
        -fuse-ld=bfd -Wl,-T,${cosmopolitan}/lib/ape.lds -include ${cosmopolitan}/lib/include/cosmopolitan.h ${cosmopolitan}/lib/crt.o ${cosmopolitan}/lib/ape.o ${cosmopolitan}/lib/cosmopolitan.a
      ${gcc9Stdenv.cc.bintools.bintools_bin}/bin/objcopy -S -O binary hello.com.dbg hello.com
      ./hello.com
      printf "test successful" > $out
    '';
  };
  meta = with lib; {
    homepage = "https://justine.lol/cosmopolitan/";
    description = "your build-once run-anywhere c library";
    platforms = platforms.all;
    license = licenses.isc;
    maintainers = [ maintainers.lourkeur maintainers.tomberek ];
  };
}
