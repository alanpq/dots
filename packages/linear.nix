# Linear only ships a Windows/macOS desktop client. The Windows NSIS installer
# bundles a platform-independent Electron app (app.asar, no native modules), so
# we unpack it and run it on nixpkgs' Linux Electron of the same major version.
{
  lib,
  stdenvNoCC,
  fetchurl,
  p7zip,
  file,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  electron_44,
}: let
  electron = electron_44; # must match the Electron major in Linear.exe ("Electron/x.y.z")
in
  stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "linear";
    version = "1.32.8";

    # Version/hash: https://releases.linear.app/latest.yml
    src = fetchurl {
      url = "https://releases.linear.app/Linear%20Setup%20${finalAttrs.version}.exe";
      hash = "sha512-0Uj1P5Th6+WkOjOHitCmvhkKc3X0KOZghwG1v5B8P+otBt5AaYQDxr7dZ3vAxACSKyvX7mh9apLLmmNc3rv4Rw==";
    };

    nativeBuildInputs = [p7zip file makeWrapper copyDesktopItems];

    unpackPhase = ''
      runHook preUnpack
      7z x "$src" '$PLUGINSDIR/app-64.7z' -y >/dev/null
      7z x '$PLUGINSDIR/app-64.7z' -oapp -y >/dev/null
      7z e app/Linear.exe '.rsrc/1033/ICON/*' -oicons -y >/dev/null
      runHook postUnpack
    '';

    postUnpack = ''
      bundled=$(grep -aoE 'Electron/[0-9]+' app/Linear.exe | head -1 | cut -d/ -f2)
      if [ "$bundled" != "${lib.versions.major electron.version}" ]; then
        echo "Linear bundles Electron $bundled but electron ${electron.version} is used; update electron_N" >&2
        exit 1
      fi
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/linear
      cp app/resources/app.asar $out/share/linear/
      if [ -d app/resources/app.asar.unpacked ]; then
        cp -r app/resources/app.asar.unpacked $out/share/linear/
      fi

      for icon in icons/*; do
        size=$(file -b "$icon" | grep -oE '[0-9]+ x [0-9]+' | cut -d' ' -f1)
        install -Dm644 "$icon" $out/share/icons/hicolor/''${size}x''${size}/apps/linear.png
      done

      makeWrapper ${lib.getExe electron} $out/bin/linear \
        --add-flags $out/share/linear/app.asar \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
        --set ELECTRON_FORCE_IS_PACKAGED 1 \
        --inherit-argv0

      runHook postInstall
    '';

    desktopItems = [
      (makeDesktopItem {
        name = "linear";
        desktopName = "Linear";
        comment = finalAttrs.meta.description;
        exec = "linear %U";
        icon = "linear";
        startupWMClass = "linear";
        categories = ["Office" "ProjectManagement"];
        mimeTypes = ["x-scheme-handler/linear"];
      })
    ];

    meta = {
      description = "Linear desktop client, repackaged from the Windows release";
      homepage = "https://linear.app";
      license = lib.licenses.unfree;
      sourceProvenance = [lib.sourceTypes.binaryBytecode];
      platforms = ["x86_64-linux" "aarch64-linux"];
      mainProgram = "linear";
    };
  })
