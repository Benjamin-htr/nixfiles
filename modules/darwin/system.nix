{
  pkgs,
  username,
  ...
}:
{
  # Keep the Unix hostname, Bonjour name, and user-facing computer name
  # consistent while respecting macOS naming constraints.
  networking = {
    hostName = "macbook-benjamin";
    localHostName = "macbook-benjamin";
    computerName = "MacBook Benjamin";
  };

  time.timeZone = "Europe/Paris";

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
    # Fast key repeat tuned for terminal and editor usage.
    NSGlobalDomain = {
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
    };

    # Keep the Dock compact and reveal it quickly when needed.
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

  # nix-darwin compatibility version; unrelated to the macOS version.
  system.stateVersion = 6;
}
