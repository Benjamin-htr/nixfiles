{ pkgs, ... }:
{
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
      # Temporary bootstrap setting. Replace it with an authorized public key
      # and set this to false before exposing SSH beyond the trusted LAN.
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = false;
    };
  };

  security.sudo.wheelNeedsPassword = true;
}
