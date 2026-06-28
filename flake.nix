{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    naviterm = {
        url = "gitlab:detoxify92/naviterm";
        inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, ... }@inputs :
    let 
      lib = nixpkgs.lib;
    in {
    nixosConfigurations = {
      north = lib.nixosSystem {
        system = "x86-64-linux";
	specialArgs = { inherit inputs; };
        modules = [ ./configuration.nix ];
      };
    };
  };
}
