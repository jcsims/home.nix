{
  pkgs,
  lib,
  specialArgs,
  ...
}: {
  home.packages =
    (lib.attrValues specialArgs.extraPackages)
    ++ [
      specialArgs.pkgs-unstable.jetbrains.idea-ultimate
      specialArgs.pkgs-unstable.graphite-cli
    ];

  services.syncthing = {
    enable = true;
    tray.enable = true;
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 600;
    pinentryPackage = pkgs.pinentry-rofi;
  };

  # According to home-manager options docs, this may be required to use the
  # `gnome3` pinentry flavor on non-Gnome systems.
  # services.dbus.packages = [ pkgs.gcr ];

  # Borrowed from https://freerangebits.com/posts/2023/12/gnupg-broke-emacs/
  programs.gpg.package = pkgs.gnupg.overrideAttrs (orig: {
    version = "2.4.0";
    src = pkgs.fetchurl {
      url = "mirror://gnupg/gnupg/gnupg-2.4.0.tar.bz2";
      hash = "sha256-HXkVjdAdmSQx3S4/rLif2slxJ/iXhOosthDGAPsMFIM=";
    };
  });

  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = ["graphical-session-pre.target"];
    };
  };
}
