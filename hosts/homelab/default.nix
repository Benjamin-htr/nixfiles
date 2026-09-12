{
  inputs,
  pkgs,
  username,
  ...
}:
{
  # Hardware settings are machine-specific; server behavior lives in the
  # reusable NixOS module.
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/server.nix
    ../../modules/nixos/containers.nix
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
    # Reuse NixOS's package set and preserve files replaced during the first
    # Home Manager activation.
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
        # Compatibility baseline, not the desired Home Manager release.
        # Do not change this value during routine upgrades.
        stateVersion = "26.05";
      };

      programs.home-manager.enable = true;
    };
  };

  # Compatibility baseline for stateful NixOS defaults. Keep this at the
  # version used for the initial installation.
  system.stateVersion = "26.05";
}
