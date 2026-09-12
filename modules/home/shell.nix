{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages = [
    pkgs.spaceship-prompt
  ];

  # Bitwarden exposes its SSH agent through this per-user macOS socket.
  home.sessionVariables = lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
    SSH_AUTH_SOCK = "${config.home.homeDirectory}/.bitwarden-ssh-agent.sock";
  };

  home.file.".spaceshiprc.zsh".source = ../../config/spaceship/spaceshiprc.zsh;

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;

    history = {
      size = 50000;
      save = 50000;
      share = true;
      ignoreAllDups = true;
      expireDuplicatesFirst = true;
    };

    initContent = ''
      # Load Spaceship from its Nix store path instead of relying on a plugin
      # manager or a mutable shell installation.
      fpath=("${pkgs.spaceship-prompt}/share/zsh/site-functions" $fpath)
      autoload -U promptinit
      promptinit
      prompt spaceship
    '';
  };
}
