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
      plexamp
      slack
      spotify
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
