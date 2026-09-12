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
  system.defaults.CustomUserPreferences = {
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

    "com.raycast.macos".raycastGlobalHotkey = "Command-49";
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
