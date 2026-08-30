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
    pkgs.mise
  ];

  xdg.configFile."mise/config.toml".text = ''
    [tools]
    dotnet = "8.0.420"
    node = "26.5.0"
    pnpm = "11.11.0"
    rust = "1.96.1"
  '';

  programs.zsh.initContent = lib.mkAfter ''
    eval "$(${lib.getExe pkgs.mise} activate zsh)"

    if command -v thefuck >/dev/null 2>&1; then
      eval "$(thefuck --alias)"
    fi
  '';
}
