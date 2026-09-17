{pkgs ? import <nixpkgs> {}}:
pkgs.writeShellScriptBin "imp" ''
  set -euo pipefail

  if [[ $# -ne 1 ]]; then
      echo "Replace a symlinked file with a writable copy of it, for quick imperative tweaks."
      echo "usage: $0 <file>" >&2
      exit 1
  fi

  file=$1

  if [[ ! -L "$file" ]]; then
      echo "error: '$file' is not a symlink" >&2
      exit 1
  fi

  real=$(realpath "$file")
  orig="''${file}.orig"

  if [[ -e "$orig" || -L "$orig" ]]; then
      echo "error: '$orig' already exists; refusing to clobber it" >&2
      exit 1
  fi

  mv "$file" "$orig"
  cp "$real" "$file"
  chmod u+w "$file"

  exec "''${EDITOR}" "$file"
''
