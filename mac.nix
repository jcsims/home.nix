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
    # nixcasks.dash
    # discord
    # Not packaged with nixcasks yet.
    #nixcasks.istat-menus
    # macOS reports launchcontrol as broken when installed via nixcasks (but
    # works fine via homebrew).
    # nixcasks.launchcontrol
    # monitorcontrol installed via nixcasks doesn't persist its start-on-login
    # behavior
    # nixcasks.monitorcontrol
    # obsidian
    # Not packaged in nixpkgs for aarch64-apple-darwin
    # nixcasks.plexamp
    # rectangle
    # Seems to be broken in both nixpkgs and nixcask
    # nixcasks.slack
    #spotify
    # Broken in nixcask, and no macOS UI in nixpkgs
    # nixcasks.syncthing
    # Tailscale also demands to be in /Applications
    # nixcasks.tailscale
    # zoom-us
  ];

  # Sync any applications installed managed via home-manager, so that Alfred
  # picks them up properly.
  home.activation = {
    aliasApplications = lib.hm.dag.entryAfter [ "writeBoundary" "linkGeneration" "installPackages" ] ''
      for app in ~/Applications/Home\ Manager\ Apps/*
      do
          app_name=''${app#~/Applications/Home\ Manager\ Apps/}
          echo "Creating alias for: $app_name"
          ${pkgs.mkalias}/bin/mkalias -L "$app" ~/nix-apps/"$app_name"
      done

      for app in ~/nix-apps/*
      do
          if ! [[ -e ~/Applications/Home\ Manager\ Apps/"''${app#~/nix-apps/}" ]]
          then
              echo "$app is getting removed"
              rm -- "$app"
          fi
      done;
    '';
  };
}
