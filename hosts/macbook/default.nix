{
  inputs,
  pkgs,
  username,
  ...
}:
{
  imports = [
    ../../modules/darwin/system.nix
    ../../modules/darwin/homebrew.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.${username}.home = "/Users/${username}";
  system.primaryUser = username;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = { inherit inputs username; };

    users.${username} = {
      imports = [
        ../../modules/home/git.nix
        ../../modules/home/shell.nix
        ../../modules/home/development.nix
        ../../modules/home/ghostty.nix
        ../../modules/home/zed.nix
        ../../modules/home/file-associations.nix
      ];

      home = {
        inherit username;
        homeDirectory = "/Users/${username}";
        stateVersion = "26.05";
      };

      programs.home-manager.enable = true;
    };
  };

  environment.shells = [ pkgs.zsh ];

  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
}
