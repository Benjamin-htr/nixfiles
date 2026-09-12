{
  inputs,
  pkgs,
  username,
  ...
}:
{
  # Compose the machine from reusable macOS modules. User-level applications
  # and dotfiles are managed separately by Home Manager below.
  imports = [
    ../../modules/darwin/system.nix
    ../../modules/darwin/homebrew.nix
    ../../modules/darwin/desktop.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.${username}.home = "/Users/${username}";
  system.primaryUser = username;

  home-manager = {
    # Reuse nix-darwin's package set and keep backups when Home Manager takes
    # ownership of an existing file for the first time.
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
        # Compatibility baseline, not the desired Home Manager release.
        # Do not change this value during routine upgrades.
        stateVersion = "26.05";
      };

      programs.home-manager.enable = true;
    };
  };

  environment.shells = [ pkgs.zsh ];

  # Expose the exact Git revision in the built system when available.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
}
