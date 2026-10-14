{
  description = "NixOS flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvim-conf.url = "github:alexperreault/nvim-conf";
    naviterm = {
      url = "git+https://gitlab.com/detoxify92/naviterm.git";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wlctl = {
      url = "github:aashish-thapa/wlctl";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in
    {
      formatter.x86_64-linux = pkgs.nixfmt-tree;
      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = with pkgs; [
          nixd
          nixfmt
          statix
          just
        ];
        shellHook = ''
          echo "Entering nix DevShell for this repo"
        '';
      };
      nixosConfigurations = {
        north = lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./devices/north/configuration.nix
          ];
        };
        rve = lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./devices/rve/configuration.nix
          ];
        };
      };
    };
}
