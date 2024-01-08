{
  pkgs,
  lib,
  system,
  specialArgs,
  ...
}: rec {
  home.packages =
    (lib.attrValues specialArgs.extraPackages)
    ++ (with pkgs; [
      _1password-gui
      alejandra
      specialArgs.pkgs-unstable.calibre
      ddcutil
      specialArgs.pkgs-unstable.jetbrains.idea-ultimate
      firefox
      specialArgs.pkgs-unstable.graphite-cli
      plexamp
      slack
      spotify
      wl-clipboard
      zoom-us
    ]);

  services.syncthing = {
    enable = true;
    tray.enable = true;
  };

  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = ["graphical-session-pre.target"];
    };
  };
}
