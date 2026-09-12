{
  config,
  lib,
  ...
}:
let
  composeSource = ../../../services/home-assistant/compose.yaml;
  composeFile = "/etc/homelab/home-assistant/compose.yaml";
  docker = lib.getExe config.virtualisation.docker.package;
in
{
  assertions = [
    {
      assertion = config.virtualisation.docker.enable;
      message = "Home Assistant requires virtualisation.docker.enable.";
    }
  ];

  # Keep the version-controlled Compose definition immutable in /etc. Runtime
  # data is stored separately under /srv so NixOS rebuilds never overwrite it.
  environment.etc."homelab/home-assistant/compose.yaml".source = composeSource;

  systemd.tmpfiles.rules = [
    "d /srv/containers/home-assistant 2770 root docker -"
    "d /srv/containers/home-assistant/config 2770 root docker -"
  ];

  # Let systemd own the Compose lifecycle so the stack starts at boot and is
  # reconciled automatically whenever its Compose definition changes.
  systemd.services.compose-home-assistant = {
    description = "Home Assistant Compose stack";
    requires = [ "docker.service" ];
    after = [
      "docker.service"
      "network-online.target"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    restartTriggers = [ composeSource ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "/etc/homelab/home-assistant";
      ExecStart = "${docker} compose --file ${composeFile} up --detach --remove-orphans";
      ExecReload = "${docker} compose --file ${composeFile} up --detach --remove-orphans";
      ExecStop = "${docker} compose --file ${composeFile} stop --timeout 60";
      TimeoutStartSec = 0;
      TimeoutStopSec = 90;
    };
  };
}
