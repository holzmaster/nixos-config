{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
 #   dotfiles.url = "github:s0la1337/dotfiles";
  };

  outputs = { self, nixpkgs, home-manager }@inputs: {
    nixosConfigurations = {
      wsl = nixpkgs.lib.nixosSystem { 
        system = "x86_64-linux";
        modules = [ 
          ./profiles/wsl/default.nix 
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      };
      neoncity = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
          ./profiles/neoncity/default.nix 
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      };
    };
  };
}