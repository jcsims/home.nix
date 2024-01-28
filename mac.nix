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
    obsidian
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
          echo "Creating alias for: $app_name"
          ${pkgs.mkalias}/bin/mkalias -L "$app" ~/nix-apps/"$app_name"
      done

      for app in ~/nix-apps/*
      do
          if ! [[ -e ~/.nix-profile/Applications/"''${app#~/nix-apps/}" ]]
          then
              echo "$app is getting removed"
              rm -- "$app"
          fi
      done;
    '';
  };
}
