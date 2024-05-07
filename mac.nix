{ config
, pkgs
, lib
, system
, ...
}: {
  home.packages = with pkgs; [
    mkalias
    terminal-notifier
  ];

  # Sync any applications installed managed via home-manager, so that Alfred
  # picks them up properly.
  home.activation = {
    aliasApplications = lib.hm.dag.entryAfter [ "writeBoundary" "linkGeneration" "installPackages" ] ''
      mkdir -p ~/nix-apps
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
