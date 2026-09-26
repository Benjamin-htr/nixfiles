{
  config,
  lib,
  pkgs,
  username,
  ...
}:
let
  composeSource = ../../../services/paperless/compose.yaml;
  envExampleSource = ../../../services/paperless/paperless.env.example;
  composeFile = "/etc/homelab/paperless/compose.yaml";
  envFile = "/var/lib/homelab/paperless/paperless.env";
  docker = lib.getExe config.virtualisation.docker.package;
in
{
  assertions = [
    {
      assertion = config.virtualisation.docker.enable;
      message = "Paperless requires virtualisation.docker.enable.";
    }
  ];

  environment.etc."homelab/paperless/compose.yaml".source = composeSource;
  environment.etc."homelab/paperless/paperless.env.example".source = envExampleSource;

  systemd.tmpfiles.rules = [
    "d /var/lib/homelab 0750 root root -"
    "d /var/lib/homelab/paperless 0750 root root -"
    "d /srv/containers/paperless 2770 root docker -"
    "d /srv/containers/paperless/data 0750 ${username} users -"
    "d /srv/containers/paperless/media 0750 ${username} users -"
    "d /srv/containers/paperless/export 0750 ${username} users -"
    "d /srv/containers/paperless/consume 0750 ${username} users -"
  ];

  systemd.services.compose-paperless = {
    description = "Paperless-ngx, PostgreSQL and Valkey Compose stack";
    requires = [ "docker.service" ];
    after = [
      "docker.service"
      "network-online.target"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    restartTriggers = [ composeSource ];
    unitConfig.ConditionPathExists = envFile;

    preStart = ''
      for secret in POSTGRES_PASSWORD PAPERLESS_SECRET_KEY PAPERLESS_ADMIN_PASSWORD; do
        if ! ${pkgs.gnugrep}/bin/grep -Eq "^$secret=.+$" '${envFile}' ||
          ${pkgs.gnugrep}/bin/grep -Eq "^$secret=CHANGE_ME" '${envFile}'; then
          echo "Set $secret in ${envFile} before starting Paperless." >&2
          exit 1
        fi
      done
    '';

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "/etc/homelab/paperless";
      ExecStart = "${docker} compose --env-file ${envFile} --file ${composeFile} up --detach --remove-orphans";
      ExecReload = "${docker} compose --env-file ${envFile} --file ${composeFile} up --detach --remove-orphans";
      ExecStop = "${docker} compose --env-file ${envFile} --file ${composeFile} stop --timeout 60";
      TimeoutStartSec = 0;
      TimeoutStopSec = 90;
    };
  };
}
