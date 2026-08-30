{
  pkgs,
  username,
  ...
}:
{
  networking = {
    hostName = "macbook-benjamin";
    localHostName = "macbook-benjamin";
    computerName = "MacBook Benjamin";
  };

  nix = {
    enable = true;
    package = pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        username
      ];
      auto-optimise-store = true;
    };
  };

  programs.zsh.enable = true;

  system.defaults = {
    NSGlobalDomain = {
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
    };

    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.2;
      largesize = 101;
      magnification = true;
      mineffect = "scale";
      persistent-apps = [ ];
      tilesize = 45;
    };
  };

  system.stateVersion = 6;
}
