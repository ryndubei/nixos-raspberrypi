# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, lib, programsdb, base-home, ... }:

let
  LAPTOP_SSH_PUBKEY =
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC5mH6j/tcTVrddxLJprJhh/XN4jwwpCYN2xsyMqI2nIWvmtXggbNK8izG4gpRBIUP3RPKGFflAEM8wKi+O1nTwDvTyp3ciJlMSbreujsnI5Uox3Ca6Dk74/9z+F7rcmXBCJlB0KBEB1v8mhQk6Lm8kRXP0lQStFuerdCyJYEEM8pQwBYtOVM/Dqp93pnLVGgD7EKLcmxWLF4g82Jx/JjSplNT19y0j14Z0Qp9TEpVe3mx51L86G0Yn30DAMDVQO5EzZUlRSEo4KxvNJCz/fpC+hfw7EZ92Yc0gF8HjfMBaKJaqtv+TpxLZMvNwE59vFnG4FyN6jLhmxOLq9Rgx1iCmiG/f7cmykDqcy5BVkzEPdVuWdRNCzhCari4Wrq4RJsRMYSCVDMEtu+Swwi0cSJe79tNBFQKC8QR9lhMEEAwNmMB+gDykH8m6J66DHLG5qb96IYbfDPTlc5PprjlTgFezzY6xuQrmyo1Dlw18AJ/H3HhJM5n2gijjcxKddTkXoo0= vasilysterekhov@nixos-laptop";
  DESKTOP_SSH_PUBKEY =
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7VuKLTmExfro8brkb2EiZ4Ce+RWRILcZ24K4n+tfmOWuNFT9j07HNoTDXocMKYp4ycUxdAmHH1wtte8hPcovjPoUJQxDvNPGUWXgiFt7us6ngyNaOp4dRX5ViW4diwvbd5djhK2b5X05tWoLw2Z45mB81VxiM4yI0vSAIr4u/BDnf2SlcPJBM1sro94QDKjKL/zIiaHFPbgeBcWkL5Lm/tEmE5JsfkKBoUPJoEmDQxG5gtqi2p8d23SzPV53dqbTK6sNnpqrhmmxpuZ26gqqXa/LW3mjRE4Q/RD/BlSnVUQkAzp9fQvuNgIswclevUhGlgeDOA+dVF+XR98VPJWR2ylx0U7g3FUBnBIyM8/0BSu/XdVzFVLobtv2qZsWVTAH/KwD4K7Ktmr9HnxUeCbfCxAmz45PWawrAdlIHPmARuy/hhIi0c53FXrjWDW2fE99usMBSOT6ADnLGa7VlVSISDL3lL2ftQFu0TLAVkmqoFvNI1YRkYAi3ooFE5dNi3E= vasilysterekhov@nixos-desktop";
  ANDROID_SSH_PUBKEY =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHXOhbRu8rmIxXdDpXX4miEKJJ4kHM15gRk6FuVTGOXy u0_a180@localhost";
in {
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Fix missing modules
  # https://github.com/NixOS/nixpkgs/issues/154163
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];

  # Disable ZFS (no cache on https://hydra.nixos.org so takes ages to compile)
  boot.supportedFilesystems.zfs = lib.mkForce false;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  console.enable = false;

  users.mutableUsers = false;
  security.sudo.wheelNeedsPassword = false;

  users.users.raspbius = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys =
      [ LAPTOP_SSH_PUBKEY DESKTOP_SSH_PUBKEY ANDROID_SSH_PUBKEY ];
    linger = true;
  };
  home-manager.users.raspbius = { ... }: {
    imports = [ base-home ];

    home.username = "raspbius";
    home.homeDirectory = "/home/raspbius";
    home.stateVersion = "24.05";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [ libraspberrypi git-crypt ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Enable Tailscale LAN-over-wireguard
  services.tailscale.enable = true;
  # Opt out of sending client logs to Tailscale
  services.tailscale.extraDaemonFlags = [ "--no-logs-no-support" ];

  programs.git.enable = true;

  # Make command-not-found work with flakes
  # https://blog.nobbz.dev/2023-02-27-nixos-flakes-command-not-found/
  environment.etc."programs.sqlite".source = programsdb;
  programs.command-not-found.dbPath = "/etc/programs.sqlite";

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

  nix.settings.trusted-public-keys = [
    # Desktop builder key
    "nixos-desktop:9+ZeV3IhjkppmYbFJPra5HG08ZmknrHIT/Fllz1h6SE="
    # Laptop builder key
    "nixos-laptop:rjk/8nZmiNg5Em+xnX/4emdDGVlpF+B/BciEEPkVxSM="
  ];
}

