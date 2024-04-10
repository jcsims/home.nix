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

  home.file.".Brewfile".source = ./files/Brewfile;

  # Sync any applications installed managed via home-manager, so that Alfred
  # picks them up properly.
  home.activation = {
    aliasApplications = lib.hm.dag.entryAfter [ "writeBoundary" "linkGeneration" "installPackages" ] ''
      mkdir -p ~/nix-apps
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
