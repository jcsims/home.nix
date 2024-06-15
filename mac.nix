{
  pkgs,
  lib,
  specialArgs,
  ...
}: {
  home.packages = with pkgs; [
    mkalias
  ];

  home.sessionVariables = {
    HOMEBREW_BUNDLE_FILE = "$HOME/.Brewfile";
  };

  home.sessionPath = [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];

  home.file.".Brewfile".source =
    if (specialArgs.work == true)
    then ./files/Brewfile-work
    else ./files/Brewfile;

  home.file.".gnupg/gpg-agent.conf".text = ''
    default-cache-ttl 600
    max-cache-ttl 7200
    pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
  '';

  # Sync any applications installed managed via home-manager, so that Alfred
  # picks them up properly.
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
    setKeyboardRateAndDelay = lib.hm.dag.entryAfter ["writeBoundary"] ''
      verboseEcho "Setting keyboard repeat rate and delay"
      run defaults write -g InitialKeyRepeat -int 15
      run defaults write -g KeyRepeat -int 2
    '';
    homebrewUpdate = lib.hm.dag.entryAfter ["writeBoundary" "linkGeneration"] ''
      if type -t brew > /dev/null && ! brew bundle check -q; then
        verboseEcho "Making sure Homebrew packages are synced"
        run brew bundle --cleanup
      fi
    '';
  };
}
