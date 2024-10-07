{ lib
, rustPlatform
, fetchFromGitHub
, makeWrapper
, pkg-config
, stdenv
, openssl
, withALSA ? stdenv.isLinux
, alsa-lib
, alsa-plugins
, withPortAudio ? false
, portaudio
, withPulseAudio ? false
, libpulseaudio
, withRodio ? true
}:

rustPlatform.buildRustPackage rec {
  pname = "librespot";
  version = "dev";

  src = fetchFromGitHub {
    owner = "librespot-org";
    repo = "librespot";
    rev = "3781a089a69ce9883a299dfd191d90c9a5348819";
    hash = "sha256-1ABtD/bYc0PHEYQLKG5HQgM+g5h680PFddLgafoh
7Kc=";
  };

  cargoSha256 = "sha256-NsnJfcLdfo+6KvWcQEUkmdtkL9IihW+rSCiXPZA50jk=";

  nativeBuildInputs = [ pkg-config makeWrapper ] ++ lib.optionals stdenv.isDarwin [
    rustPlatform.bindgenHook
  ];

  buildInputs = [ openssl ]
    ++ lib.optional withALSA alsa-lib
    ++ lib.optional withPortAudio portaudio
    ++ lib.optional withPulseAudio libpulseaudio;

  buildNoDefaultFeatures = true;
  buildFeatures = lib.optional withRodio "rodio-backend"
    ++ lib.optional withALSA "alsa-backend"
    ++ lib.optional withPortAudio "portaudio-backend"
    ++ lib.optional withPulseAudio "pulseaudio-backend";

  postFixup = lib.optionalString withALSA ''
    wrapProgram "$out/bin/librespot" \
      --set ALSA_PLUGIN_DIR '${alsa-plugins}/lib/alsa-lib'
  '';

  meta = with lib; {
    description = "Open Source Spotify client library and playback daemon";
    mainProgram = "librespot";
    homepage = "https://github.com/librespot-org/librespot";
    changelog = "https://github.com/librespot-org/librespot/blob/v${version}/CHANGELOG.md";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ bennofs ];
  };
}
