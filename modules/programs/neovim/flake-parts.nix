{...}: {
  flake-file.inputs = {
    neovim = {
      url = "github:alanpq/neovim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
