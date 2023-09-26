{
  mkOverlays = allPkgs:
    builtins.listToAttrs (builtins.map (pkgName: {
      name = pkgName;
      value = final: prev: { ${pkgName} = allPkgs.${prev.system}.${pkgName}; };
    }) (builtins.attrNames
      # elemAt fine for now I guess
      (builtins.elemAt (builtins.attrValues allPkgs) 1)));
}