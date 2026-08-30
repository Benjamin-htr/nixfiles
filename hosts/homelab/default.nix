{
  inputs,
  pkgs,
  username,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/server.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "homelab";

  users.users.${username} = {
    isNormalUser = true;
    description = "Benjamin";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = { inherit inputs username; };

    users.${username} = {
      imports = [
        ../../modules/home/git.nix
        ../../modules/home/shell.nix
      ];

      home = {
        inherit username;
        homeDirectory = "/home/${username}";
        stateVersion = "26.05";
      };

      programs.home-manager.enable = true;
    };
  };

  system.stateVersion = "26.05";
}
