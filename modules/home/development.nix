{
  lib,
  pkgs,
  ...
}:
{
  home.packages = [
    pkgs.duti
    pkgs.gh
    pkgs.just
    # Nix installs Mise itself; Mise installs and selects project runtimes.
    pkgs.mise
  ];

  # Pin global fallback versions. A project's mise.toml can override these
  # versions locally without rebuilding the system configuration.
  xdg.configFile."mise/config.toml".text = ''
    [tools]
    dotnet = "8.0.420"
    node = "26.5.0"
    pnpm = "11.11.0"
    rust = "1.96.1"
  '';

  programs.zsh.initContent = lib.mkAfter ''
    eval "$(${lib.getExe pkgs.mise} activate zsh)"

    # `thefuck` is installed by Homebrew on macOS, so only initialize it when
    # the command exists (the shared module may also be used on Linux later).
    if command -v thefuck >/dev/null 2>&1; then
      eval "$(thefuck --alias)"
    fi
  '';
}
