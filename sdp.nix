{ pkgs, lib, config, ... }:

let
  ssh-keys = config.users.raspbius.openssh.authorizedKeys.keys;

  adminUser = name: {
    users.users.${name} = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = ssh-keys;
      password = "group13";
      linger = true;
    };
    home-manager.users.${name} = { ... }: {
      home.username = name;
      home.homeDirectory = "/home/${name}";
    };
  };

  adminUsers = names: builtins.foldl' (n: acc: acc // (adminUser n));

in {
  networking.wireless.enable = true;

  networking.wireless.networks."SDProbots".psk = "robotsRus";

  # SDProbots has no DHCP, must use static IP
  networking.interfaces.wlan0.useDHCP = false;
  networking.interfaces.wlan0.ipv4.addresses = [{
    address = "192.168.105.169";
    prefixLength = 24;
  }];
  networking.defaultGateway = "192.168.105.243";

  # don't think inf would react well to tailscale, will have to just
  # SSH through student.ssh.inf.ed.ac.uk -> sdp-ranger
  services.tailscale.enable = lib.mkForce false;

  # syncthing will use ~6% of RAM otherwise
  home-manager.users.raspbius.services.syncthing.enable = lib.mkForce false;

  virtualisaton.containers.enable = true;

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  environment.systemPackages = with pkgs; [ distrobox ];

  # Enable password login over the terminal
  users.users.raspbius.password = "group13";
  console.enable = lib.mkForce true;
} // (adminUsers [
  "sholto"
  "kian"
  "remi"
  "bruce"
  "eric"
  "pelayo"
  "pani"
  "vasily"
])
