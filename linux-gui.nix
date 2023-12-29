{ pkgs
, lib
, system
, specialArgs
, ...
}: rec {
  home.packages =
    (lib.attrValues specialArgs.extraPackages)
    ++ (with pkgs; [
      _1password-gui
      alejandra
      specialArgs.pkgs-unstable.calibre
      firefox
      plexamp
      slack
      spotify
      wl-clipboard
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
