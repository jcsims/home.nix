{ config
, pkgs
, lib
, system
, ...
}: {
  home.packages = with pkgs; [
    terminal-notifier
  ];

  # Sync any applications installed managed via home-manager, so that Alfred
  # picks them up properly.
  home.activation = {
    rsyncApplications = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    for app in ~/.nix-profile/Applications/*
    do
        if ! [[ -e ~/nix-apps/''${app#~/.nix-profile/Applications/} ]]
        then
            echo installing new app "''${app#~/.nix-profile/Applications/}"
            rsync -qLr -- "$app" ~/nix-apps
        elif ! diff -qr $app ~/nix-apps/''${app#~/.nix-profile/Applications/} 1> /dev/null
        then
            echo updating "''${app#~/.nix-profile/Applications/}"
            rsync -qLr --delete -- "$app" ~/nix-apps
        fi
    done

    for app in ~/nix-apps/*
    do
        if ! [[ -e ~/.nix-profile/Applications/''${app#~/nix-apps/} ]]
        then
            echo "$app is getting removed"
            rm -rf -- "$app"
        fi
    done;
    '';
  };
}
