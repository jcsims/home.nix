{
  pkgs,
  lib,
  specialArgs,
  ...
}: {
  home.packages = with pkgs; [
    mkalias
  ];

  home.sessionPath = [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];

  home.file.".Brewfile".source =
    if (specialArgs.work == true)
    then ./files/Brewfile-work
    else ./files/Brewfile;

  launchd.agents.nix-index-build = {
    enable = true;
    config = {
      Program = "${pkgs.nix-index}/bin/nix-index";
      ProcessType = "Background";

      StartCalendarInterval = [
        {
          Weekday = 0;
          Hour = 8;
          Minute = 0;
        }
      ];
    };
  };

  # Create aliases for any applications installed managed via home-manager, so
  # that Alfred picks them up properly.
  home.activation = {
    aliasApplications = lib.hm.dag.entryAfter ["writeBoundary" "linkGeneration" "installPackages"] ''
      run mkdir -p ~/nix-apps
      for app in ~/.nix-profile/Applications/*
      do
          app_name=''${app#~/.nix-profile/Applications/}
          verboseEcho "Creating alias for: $app_name"
          run ${pkgs.mkalias}/bin/mkalias -L "$app" ~/nix-apps/"$app_name"
      done

      for app in ~/nix-apps/*
      do
          if ! [[ -e ~/.nix-profile/Applications/"''${app#~/nix-apps/}" ]]
          then
              verboseEcho "$app is getting removed"
              run rm -- "$app"
          fi
      done;
    '';

    # Make jdk17 available system-wide for CLI and GUI apps. This is the same
    # approach that Homebrew recommends.
    linkjdk = lib.hm.dag.entryAfter ["writeBoundary" "linkGeneration" "installPackages"] ''
      jdk_path="${pkgs.jdk17}/zulu-17.jdk"
      if [[ "$(realpath /Library/Java/JavaVirtualMachines/zulu-17.jdk)" != "$jdk_path" ]]; then
        verboseEcho "Symlinking the installed JDK so it's available system-wide..."
        run sudo ln -sf "$jdk_path" "/Library/Java/JavaVirtualMachines/"
      fi
    '';

    setStatefulConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      verboseEcho "Setting some stateful macOS config"
      run defaults write -g InitialKeyRepeat -int 15
      run defaults write -g KeyRepeat -int 2
      # This disables the too-bold font in Alacritty
      run defaults write org.alacritty AppleFontSmoothing -int 0
    '';

    # TODO: Don't write ~/.Brewfile, but either use `--file=-` and pipe the file
    # to stdin, or write the Brewfile into the store and reference it from the
    # store.
    homebrewUpdate = lib.hm.dag.entryAfter ["writeBoundary" "linkGeneration"] ''
      if type -t brew > /dev/null && ! brew bundle check -q --file ~/.Brewfile; then
        verboseEcho "Making sure Homebrew packages are synced"
        run brew bundle --cleanup --file ~/.Brewfile
      fi
    '';
  };
}
