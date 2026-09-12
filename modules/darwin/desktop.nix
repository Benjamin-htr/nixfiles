{
  lib,
  username,
  ...
}:
let
  qwertyFr = {
    InputSourceKind = "Keyboard Layout";
    "KeyboardLayout ID" = -7247;
    "KeyboardLayout Name" = "qwerty-fr";
  };

  characterPalette = {
    "Bundle ID" = "com.apple.CharacterPaletteIM";
    InputSourceKind = "Non Keyboard Input Method";
  };

  pressAndHold = {
    "Bundle ID" = "com.apple.PressAndHold";
    InputSourceKind = "Non Keyboard Input Method";
  };

  escapedUsername = lib.escapeShellArg username;
in
{
  system.defaults = {
    # Mouse settings matching the preferred System Settings slider positions.
    # The speed keys require raw macOS defaults because nix-darwin does not
    # expose dedicated typed options for them.
    NSGlobalDomain."com.apple.swipescrolldirection" = true;

    CustomUserPreferences = {
      NSGlobalDomain = {
        "com.apple.mouse.scaling" = 0.5;
        "com.apple.mouse.doubleClickThreshold" = 0.5;
        "com.apple.scrollwheel.scaling" = 0.3125;
      };

      # Enable right-side secondary click in both the user and Bluetooth Magic
      # Mouse preference domains.
      "com.apple.AppleMultitouchMouse".MouseButtonMode = "TwoButton";
      "com.apple.driver.AppleBluetoothMultitouch.mouse".MouseButtonMode = "TwoButton";

      # Make qwerty-fr the primary input source without removing the macOS
      # character palette and press-and-hold input methods.
      "com.apple.HIToolbox" = {
        AppleCurrentKeyboardLayoutInputSourceID =
          "com.apple.keyboardlayout.qwerty-fr.keylayout.qwerty-fr";
        AppleEnabledInputSources = [
          qwertyFr
          characterPalette
          pressAndHold
        ];
        AppleInputSourceHistory = [ qwertyFr ];
        AppleSelectedInputSources = [
          qwertyFr
          pressAndHold
        ];
      };

      # Key code 49 is the space bar, so this assigns Cmd-Space to Raycast.
      "com.raycast.macos".raycastGlobalHotkey = "Command-49";
    };
  };

  # Keep all other macOS shortcuts intact while freeing Cmd-Space for Raycast.
  system.activationScripts.userDefaults.text = lib.mkAfter ''
    user_uid="$(/usr/bin/id -u -- ${escapedUsername})"
    /bin/launchctl asuser "$user_uid" /usr/bin/sudo --user=${escapedUsername} -- \
      /usr/bin/defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys \
        -dict-add 64 \
        '{ enabled = 0; value = { parameters = (65535, 49, 1048576); type = standard; }; }'
  '';

  launchd.user.agents.raycast.serviceConfig = {
    ProgramArguments = [
      "/usr/bin/open"
      "-gj"
      "/Applications/Raycast.app"
    ];
    ProcessType = "Interactive";
    RunAtLoad = true;
  };

  # The launch agent is loaded before Homebrew during the first activation.
  # Start Raycast once more after its cask has been installed.
  system.activationScripts.postActivation.text = lib.mkAfter ''
    if [[ -d /Applications/Raycast.app ]]; then
      user_uid="$(/usr/bin/id -u -- ${escapedUsername})"
      /bin/launchctl asuser "$user_uid" /usr/bin/sudo --user=${escapedUsername} -- \
        /usr/bin/open -gj /Applications/Raycast.app
    fi
  '';
}
