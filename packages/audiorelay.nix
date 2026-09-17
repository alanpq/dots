{
  stdenv,
  dpkg,
  fetchurl,
  buildFHSEnv,
  writeShellScript,
}: let
  unpacked = stdenv.mkDerivation rec {
    pname = "AudioRelay";
    version = "0.27.5";
    src = fetchurl {
      url = "https://dl.audiorelay.net/setups/linux/audiorelay-${version}.deb";
      hash = "sha256-tLANO6IXGN9hAhpny3s+qrXfqqd5vvfjJHBUoHnNPe4=";
    };
    nativeBuildInputs = [dpkg];
    installPhase = ''
      mkdir $out
      cp -r . $out
    '';
  };
  run = writeShellScript "foo-run" ''
    exec ${unpacked}/opt/audiorelay/bin/AudioRelay "$@"
  '';
in
  buildFHSEnv {
    name = "AudioRelay";
    pname = "AudioRelay";
    version = "0.27.5";
    targetPkgs = pkgs:
      with pkgs; [
        glib
        gtk3
        cairo
        pango
        libx11
        libxext
        libxfixes
        libxrender
        libxrandr
        libxcomposite
        libxdamage
        libxcb
        libxtst
        libxi
        libpulseaudio
        libxft
        freetype
        fontconfig
        libxkbcommon
        libdrm
        libGL
        mesa
        alsa-lib
        nss
        nspr
        cups
        dbus
        expat
        zlib
      ];
    multiPkgs = pkgs: [];
    runScript = run;
    meta = {
      mainProgram = "AudioRelay";
    };
  }
