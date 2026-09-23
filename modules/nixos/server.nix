{ pkgs, ... }:
{
  # Boot directly through UEFI and retain a small number of generations in the
  # boot menu for recovery.
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
    };
    tmp.cleanOnBoot = true;
  };

  hardware.enableRedistributableFirmware = true;

  networking = {
    networkmanager.enable = true;
    # The server is administered over SSH; application traffic will later pass
    # through the tunnel instead of opening additional router-facing ports.
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };

    # Bound the Nix store growth while retaining recent rollback generations.
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  programs.zsh.enable = true;

  environment.systemPackages = [
    pkgs.git
    pkgs.just
  ];

  services.openssh = {
    enable = true;
    openFirewall = false;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  security.sudo.wheelNeedsPassword = true;
}
