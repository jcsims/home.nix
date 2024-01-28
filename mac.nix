{ config
, pkgs
, lib
, system
, ...
}: {
  home.packages = with pkgs; [
    mkalias
    terminal-notifier
    # 1Password requires an install inside /Applications to be happy
    # _1password-gui
    # macOS reports Alfred as broken when installed via nixcasks (but works fine
    # in homebrew).
    # nixcasks.alfred
    nixcasks.dash
    discord
    # Not packaged with nixcasks yet.
    #nixcasks.istat-menus
    iterm2
    # macOS reports launchcontrol as broken when installed via nixcasks (but
    # works fine via homebrew).
    # nixcasks.launchcontrol
    nixcasks.monitorcontrol
    nixcasks.obsidian
    # Not packaged in nixpkgs for aarch64-apple-darwin
    nixcasks.plexamp
    rectangle
    # Seems to be broken in both nixpkgs and nixcask
    # nixcasks.slack
    spotify
    # Broken in nixcask, and no macOS UI in nixpkgs
    # nixcasks.syncthing
    zoom-us
  ];

  # Sync any applications installed managed via home-manager, so that Alfred
  # picks them up properly.
  home.activation = {
    rsyncApplications = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      for app in ~/.nix-profile/Applications/*
      do
          app_name=''${app#~/.nix-profile/Applications/}
          if ! [[ -e ~/nix-apps/"$app_name" ]]
          then
              echo installing new app "$app_name"
              ${pkgs.mkalias}/bin/mkalias -L "$app" ~/nix-apps/"$app_name"
              #rsync -qLr -- "$app" ~/nix-apps
          # elif ! diff -qr "$app" ~/nix-apps/"$app_name" 1> /dev/null
          # then
          #     echo updating "$app_name"
          #     rsync -qLr --delete -- "$app" ~/nix-apps
          fi
      done

      for app in ~/nix-apps/*
      do
          if ! [[ -e ~/.nix-profile/Applications/"''${app#~/nix-apps/}" ]]
          then
              echo "$app is getting removed"
              rm -rf -- "$app"
          fi
      done;
    '';
  };
}
