{
  description = "NixOS flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
        url = "github:nix-community/home-manager/master";
        inputs.nixpkgs.follows = "nixpkgs";
    };
    naviterm = {
        url = "gitlab:detoxify92/naviterm";
        inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fsel = {
      url = "github:Mjoyufull/fsel";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs :
    let 
      lib = nixpkgs.lib;
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
    in {
    nixosConfigurations = {
      north = lib.nixosSystem {
	specialArgs = { inherit inputs; };
        modules = [ 
	  ./configuration.nix 
          { nixpkgs.hostPlatform = "x86_64-linux"; }
	];
      };
      };
    homeConfigurations = {
      alexp = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ 
	  ./home.nix 
	];
      };

    };
  };
}
