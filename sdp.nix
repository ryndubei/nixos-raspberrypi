{ pkgs, lib, config, ... }:

let
  ssh-keys = config.users.users.raspbius.openssh.authorizedKeys.keys;

  # note:
  # https://discourse.nixos.org/t/running-nix-os-containers-directly-from-the-store-with-podman/29220
  # podman run -ti --rm -v /nix/store:/nix/store --rootfs ./result:O /bin/hello
  rosImage = pkgs.dockerTools.pullImage {
    imageName = "ros";
    imageDigest =
      "sha256:ed1544e454989078f5dec1bfdabd8c5cc9c48e0705d07b678ab6ae3fb61952d2";
    sha256 = "1bc8s1j9311qwg748s2qjjmr5f8yz14j5hhf63azc2l7kswmfq98";
    finalImageName = "ros";
    finalImageTag = "humble-perception";
    arch = "arm64";
  };

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

  environment.systemPackages = with pkgs; [
    distrobox
    podman-tui
    (writeShellScriptBin "enter-ros-shell" ''
      set -euxo pipefail
      ${podman}/bin/podman run -ti --rm -v /nix/store:/nix/store -v "$HOME":"/home/$USER" --user "$USER" --rootfs ${rosImage}:O ${bash}/bin/bash
    '')
  ];

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
