{ pkgs, lib, config, ... }:

let
  ssh-keys = config.users.users.raspbius.openssh.authorizedKeys.keys;

  # note:
  # https://discourse.nixos.org/t/running-nix-os-containers-directly-from-the-store-with-podman/29220
  # podman run -ti --rm -v /nix/store:/nix/store --rootfs ./result:O /bin/hello
  rosImage = pkgs.dockerTools.pullImage {
    imageName = "ros";
    imageDigest =
      "sha256:80dfc9ff2ada919636ef0038dbb65a8b24ef89ac4cd8126bf59271f743033966";
    sha256 = "0sy8vvghnd8h075fsbj0mkpszdb7rwy5y67nql2r2llmszaycd1c";
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
