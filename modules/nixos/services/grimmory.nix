{
  config,
  lib,
  pkgs,
  username,
  ...
}:
let
  composeSource = ../../../services/grimmory/compose.yaml;
  envExampleSource = ../../../services/grimmory/grimmory.env.example;
  composeFile = "/etc/homelab/grimmory/compose.yaml";
  envFile = "/var/lib/homelab/grimmory/grimmory.env";
  docker = lib.getExe config.virtualisation.docker.package;
in
{
  assertions = [
    {
      assertion = config.virtualisation.docker.enable;
      message = "Grimmory requires virtualisation.docker.enable.";
    }
    {
      assertion = config.users.users.${username}.uid != null;
      message = "Grimmory requires an explicit UID for the homelab user.";
    }
  ];

  # Keep the Compose definition and a safe template in /etc. The real env file
  # is created manually on the server and is never stored in this repository.
  environment.etc."homelab/grimmory/compose.yaml".source = composeSource;
  environment.etc."homelab/grimmory/grimmory.env.example".source = envExampleSource;

  systemd.tmpfiles.rules = [
    "d /var/lib/homelab 0750 root root -"
    "d /var/lib/homelab/grimmory 0750 root root -"
    "d /srv/containers/grimmory 0750 ${username} users -"
    "d /srv/containers/grimmory/mariadb 0750 ${username} users -"
    "d /srv/containers/grimmory/mariadb/config 0750 ${username} users -"
    "d /srv/containers/grimmory/data 0750 ${username} users -"
    "d /srv/containers/grimmory/books 0750 ${username} users -"
    "d /srv/containers/grimmory/bookdrop 0750 ${username} users -"
  ];

  # This service is skipped until the administrator creates the secret env
  # file. A copied template is rejected to prevent weak default passwords.
  systemd.services.compose-grimmory = {
    description = "Grimmory and MariaDB Compose stack";
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
      if ${pkgs.gnugrep}/bin/grep -q 'CHANGE_ME' '${envFile}'; then
        echo "Replace CHANGE_ME values in ${envFile} before starting Grimmory." >&2
        exit 1
      fi
    '';

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "/etc/homelab/grimmory";
      ExecStart = "${docker} compose --env-file ${envFile} --file ${composeFile} up --detach --remove-orphans";
      ExecReload = "${docker} compose --env-file ${envFile} --file ${composeFile} up --detach --remove-orphans";
      ExecStop = "${docker} compose --env-file ${envFile} --file ${composeFile} stop --timeout 60";
      TimeoutStartSec = 0;
      TimeoutStopSec = 90;
    };
  };
}
