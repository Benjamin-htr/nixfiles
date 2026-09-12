{
  username,
  ...
}:
{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;

    # Keep the storage backend stable across Docker upgrades. overlay2 is the
    # recommended driver for the ext4 filesystem used by this host.
    storageDriver = "overlay2";

    daemon.settings = {
      # Keep running containers alive when the Docker daemon is restarted by a
      # NixOS rebuild. This is incompatible with Docker Swarm, which we do not
      # use on this single-node homelab.
      live-restore = true;
    };

    autoPrune = {
      enable = true;
      dates = "weekly";
      randomizedDelaySec = "1h";

      # Only remove unused resources older than one week. Volumes are excluded
      # intentionally because they will contain persistent application data.
      flags = [ "--filter=until=168h" ];
    };
  };

  # Docker socket access is equivalent to root access. This is acceptable for
  # the single trusted administrator account on this private server.
  users.users.${username}.extraGroups = [ "docker" ];

  # Compose files and bind-mounted application data will live here. The setgid
  # bit keeps new files in the docker group for consistent administration.
  systemd.tmpfiles.rules = [
    "d /srv/containers 2770 root docker -"
  ];
}
