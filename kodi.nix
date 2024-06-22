{ pkgs, ... }:

let
  kodi-wayland-with-plugins = pkgs.kodi-wayland.passthru.withPackages (kodiPkgs: with kodiPkgs; [
    # Add Kodi plugins here
  ]);
in
{
  # See https://nixos.wiki/wiki/Kodi

  # Define a user account
  users.extraUsers.kodi.isNormalUser = true;

  # Run Kodi (Wayland) in kiosk mode 
  services.cage.user = "kodi";
  services.cage.program = "${kodi-wayland-with-plugins}/bin/kodi-standalone";
  services.cage.enable = true;
}
