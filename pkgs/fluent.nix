{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  variant ? "",
}: let
  pname = "fluent-kvantum";
in
  lib.checkListOfEnum "${pname}: color variant" ["green" "grey" "orange" "pink" "purple" "red" "round-solid" "round" "solid" "teal" "yellow" ""] [variant]

  stdenvNoCC.mkDerivation {
    inherit pname;
    version = "unstable-2022-09-27";

    src = fetchFromGitHub {
      owner = "vinceliuice";
      repo = "Fluent-kde";
      rev = "83d5cc2013751aa9eeb944dafa3a3460652690ce";
      sha256 = "09ja52524h6d50jxpv1xfswf6lw9bqa1f6r6q0gcnmqn1av36vwf";
    };

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/Kvantum
      cp -a Kvantum/${if variant != "" then "Fluent-${variant}" else "Fluent"} $out/share/Kvantum
      runHook postInstall
    '';

    meta = with lib; {
      description = "A kvantum theme based on Fluent Design elements. ";
      homepage = "https://github.com/vinceliuice/Fluent-kde";
      license = licenses.gpl3Only;
      platforms = platforms.linux;
    };
  }