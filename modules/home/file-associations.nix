{
  lib,
  pkgs,
  ...
}:
let
  editorBundleId = "dev.zed.Zed";
in
{
  home.activation.defaultEditorAssociations = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    for type in \
      public.plain-text \
      public.data \
      public.text \
      public.source-code \
      public.unix-shell-script \
      com.net.sourceforge.sed \
      txt md json yaml yml xml html css js ts py rs toml zsh bash sh log conf
    do
      $DRY_RUN_CMD ${lib.getExe pkgs.duti} -s ${editorBundleId} "$type" all
    done
  '';
}
