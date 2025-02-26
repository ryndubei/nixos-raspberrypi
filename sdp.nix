{ pkgs, lib, config, ... }:

let
  ssh-keys = config.users.users.raspbius.openssh.authorizedKeys.keys;

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
      home.stateVersion = "24.05";
    };
  };

  adminUsers = names: builtins.foldl' (acc: n: acc // (adminUser n)) { } names;
in {
  networking.wireless.enable = true;

  networking.wireless.networks."ranger-hotspot".psk = "12345678";

  # syncthing will use ~6% of RAM otherwise
  home-manager.users.raspbius.services.syncthing.enable = lib.mkForce false;

  virtualisation.containers.enable = true;

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
