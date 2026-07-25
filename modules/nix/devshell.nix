{
    perSystem = {pkgs, ...}: {
        devShells.default = pkgs.mkShell {
            packages = with pkgs; [
                nix
                nixpkgs-fmt
                alejandra

                stylua

                git
                git-crypt

                sops
                ssh-to-age
                gnupg
                age
                
                nh

                bun
                typescript
                typescript-language-server

                kdePackages.qtdeclarative
            ];
        };
    };
}
