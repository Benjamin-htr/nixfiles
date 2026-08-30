{ username, ... }:
{
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

    casks = [
      "arc"
      "bitwarden"
      "cmdcmd"
      "copilot-cli"
      "discord"
      "ghostty"
      "godot"
      "keka"
      "logi-options+"
      "megasync"
      "orbstack"
      "proton-mail"
      "qobuz"
      "qwerty-fr"
      "raycast"
      "updf"
      "zed"
    ];
  };
}
