{ ... }:
{
  programs.git = {
    enable = true;
    ignores = [
      ".DS_Store"
      ".DS_Store?"
      "._*"
      ".direnv/"
      ".env"
      ".env.*"
      "result"
      "result-*"
    ];
    settings = {
      user = {
        name = "Benjamin-htr";
        email = "benjamin.htr42@gmail.com";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };
}
