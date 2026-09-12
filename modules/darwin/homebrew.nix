{ username, ... }:
{
  # nix-homebrew owns the Homebrew installation itself; nix-darwin manages the
  # formulae and casks declared below.
  nix-homebrew = {
    enable = true;
    enableRosetta = false;
    user = username;
    autoMigrate = true;
    mutableTaps = true;
  };

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      upgrade = false;
      # Keep anything not declared during the first migration. Once the
      # configuration is stable this can be changed to "check".
      cleanup = "none";
    };

    brews = [ "thefuck" ];

    # GUI applications that are unavailable or better maintained as Homebrew
    # casks rather than Nix packages on macOS.
    casks = [
      "arc"
      "bitwarden"
      "discord"
      "ghostty"
      "keka"
      "logi-options+"
      "megasync"
      "orbstack"
      "qwerty-fr"
      "raycast"
      "zed"
    ];
  };
}
