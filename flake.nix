{
  description = "Benjamin's macOS and homelab configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-darwin,
      nix-darwin,
      home-manager,
      nix-homebrew,
      ...
    }:
    let
      username = "benjamin";
    in
    {
      darwinConfigurations.macbook-benjamin = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs username; };
        modules = [
          ./hosts/macbook
          home-manager.darwinModules.home-manager
          nix-homebrew.darwinModules.nix-homebrew
        ];
      };

      nixosConfigurations.homelab = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs username; };
        modules = [
          ./hosts/homelab
          home-manager.nixosModules.home-manager
        ];
      };

      checks = {
        aarch64-darwin.macbook-benjamin = self.darwinConfigurations.macbook-benjamin.system;
        x86_64-linux.homelab = self.nixosConfigurations.homelab.config.system.build.toplevel;
      };

      formatter = {
        aarch64-darwin = nixpkgs-darwin.legacyPackages.aarch64-darwin.nixfmt;
        aarch64-linux = nixpkgs.legacyPackages.aarch64-linux.nixfmt;
        x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;
      };
    };
}
