{inputs, ...}: {
  flake-file.inputs = {
    hjem-rum = {
      url = "github:snugnug/hjem-rum";
      inputs.nixpkgs.follows = "nixpkgs";
      # inputs.hjem.follows = "hjem";
    };
    hjem.follows = "hjem-rum/hjem";
  };
}
