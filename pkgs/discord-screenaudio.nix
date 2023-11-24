{ lib
, stdenv
, fetchgit
, fetchFromGitHub
, variant ? ""
, cmake
, extra-cmake-modules
, qt5
, knotifications
, wrapQtAppsHook
, pipewire
, pkg-config
,
}:
let
  pname = "discord-screenaudio";
in
stdenv.mkDerivation
rec {
  inherit pname;
  version = "master";

  src = fetchgit {
    url = "https://github.com/maltejur/discord-screenaudio.git";
    hash = "sha256-pD3NtDRqpi3too7jKGvno9QkYN6pSbP/hycRqS2SwaE=";
    # deepClone = true;
    fetchSubmodules = true;
  };

  buildInputs = [
    pkg-config
    knotifications
    # pipewire
    pipewire.dev
    # pipewire.lib
    qt5.qtbase
    qt5.qtwebengine
  ];

  nativeBuildInputs = [
    pkg-config
    cmake
    extra-cmake-modules
    wrapQtAppsHook
    # pipewire
    # pipewire.dev
    # pipewire.lib
  ];

  meta = with lib; {
    description = "A custom discord client that supports streaming with audio on Linux ";
    homepage = "https://github.com/maltejur/discord-screenaudio";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
