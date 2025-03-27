{
  pkgs,
  lib,
  specialArgs,
  ...
}:
let
  check-for-sync-conflicts = pkgs.writeShellScript "check-for-sync-conflicts" ''
    status=0
    sync_paths=(
        "$HOME/Downloads"
        "$HOME/books"
        "$HOME/synced-config"
        "$HOME/synced-docs"
        "$HOME/wallpapers"
        "$HOME/work-docs"
           )

    for path in "$${sync_paths[@]}"; do
        if [[ -d $path ]]; then

            conflicts=$(${pkgs.fd}/bin/fd -I -H --exclude .stversions .sync-conflict- "$path")

            if [[ $conflicts ]] ; then
                echo "there are conflicts in $path:" >> $HOME/problems
                echo "$conflicts" >> $HOME/problems
            else
                # do nothing, things are good
                status=$((status + 1))
            fi
        fi
    done
  '';

  check-problems = pkgs.writeShellScript "check-problems" ''
    if [ -s "$HOME"/problems ] ; then
      /opt/homebrew/bin/terminal-notifier \
          -title "There's a problem!" \
          -message "$(head -n 1 "$HOME"/problems)"
    fi
  '';
  sync-org-roam = pkgs.writeShellScript "sync-org-roam" ''
    # Only attempt this if the screen is unlocked
    if [ "$(/usr/libexec/PlistBuddy -c "print :IOConsoleUsers:0:CGSSessionScreenIsLocked" /dev/stdin 2>/dev/null <<< "$(ioreg -n Root -d1 -a)")" != "true" ]; then
      cd ~/org-roam
      if ! ./sync; then
        echo "org-roam sync failed! $(date)" >> "$HOME/problems"
      fi
    fi
  '';
in
{
  home.sessionPath = [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];

  home.file.".Brewfile".source =
    if (specialArgs.work == true) then ./files/Brewfile-work else ./files/Brewfile;

  launchd.agents = {
    check-for-sync-conflicts = {
      enable = true;
      config = {
        Program = "${check-for-sync-conflicts}";
        ProcessType = "Background";
        StartCalendarInterval = [ { Minute = 30; } ];
        StandardOutPath = "/tmp/check-for-sync-conflicts-out.log";
        StandardErrorPath = "/tmp/check-for-sync-conflicts-err.log";
      };
    };
    check-problems = {
      enable = true;
      config = {
        Program = "${check-problems}";
        ProcessType = "Background";
        StandardOutPath = "/tmp/check-problems-out.log";
        StandardErrorPath = "/tmp/check-problems-err.log";
        WatchPaths = [ "${specialArgs.homedir}/problems" ];
      };
    };
    nix-index-build = {
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
    sync-org-roam = {
      enable = true;
      config = {
        Program = "${sync-org-roam}";
        ProcessType = "Background";
        StartCalendarInterval = [ { Minute = 30; } ];
        StandardOutPath = "/tmp/sync-org-roam-out.log";
        StandardErrorPath = "/tmp/sync-org-roam-err.log";
      };
    };
  };

  # Create aliases for any applications installed via home-manager, so that
  # Alfred picks them up properly.
  home.activation = {
    aliasApplications =
      lib.hm.dag.entryAfter
        [
          "writeBoundary"
          "linkGeneration"
          "installPackages"
        ]
        ''
          run mkdir -p ~/nix-apps
          for app in ~/.nix-profile/Applications/*
          do
              app_name=''${app#~/.nix-profile/Applications/}
              verboseEcho "Creating alias for: $app_name"
              run ${pkgs.mkalias}/bin/mkalias "$app" ~/nix-apps/"$app_name"
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
    linkjdk =
      lib.hm.dag.entryAfter
        [
          "writeBoundary"
          "linkGeneration"
          "installPackages"
        ]
        ''
          jdk_path="${pkgs.jdk17}/zulu-17.jdk"
          if [[ "$(realpath /Library/Java/JavaVirtualMachines/zulu-17.jdk)" != "$jdk_path" ]]; then
            verboseEcho "Symlinking the installed JDK so it's available system-wide..."
            run sudo ln -sf "$jdk_path" "/Library/Java/JavaVirtualMachines/"
          fi
        '';

    setStatefulConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      verboseEcho "Setting some stateful macOS config"

      # Configure the keyboard
      run defaults write -g InitialKeyRepeat -int 15
      run defaults write -g KeyRepeat -int 2
      run defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

      # This disables the too-bold font in Alacritty
      run defaults write org.alacritty AppleFontSmoothing -int 0

      # Trackpad
      verboseEcho "Setting the proper scroll direction"
      run defaults write -g com.apple.swipescrolldirection -boolean NO

      verboseEcho "Configuring the Dock"
      run defaults write com.apple.dock orientation -string left
      run defaults write com.apple.dock tilesize -int 40
      # Don't show recent apps in the Dock
      run defaults write com.apple.dock show-recents -bool false
      # This only shows open applications, which is awesome
      run defaults write com.apple.dock static-only -bool true
      # This makes hidden apps slightly darker
      run defaults write com.apple.dock showhidden -bool true

      verboseEcho "configuring Finder"
      run defaults write com.apple.finder ShowPathbar -bool true
    '';

    # TODO: Don't write ~/.Brewfile, but either use `--file=-` and pipe the file
    # to stdin, or write the Brewfile into the store and reference it from the
    # store.
    homebrewUpdate =
      lib.hm.dag.entryAfter
        [
          "writeBoundary"
          "linkGeneration"
        ]
        ''
          if type -t brew > /dev/null && ! brew bundle check -q --file ~/.Brewfile; then
            verboseEcho "Making sure Homebrew packages are synced"
            run brew bundle --cleanup --file ~/.Brewfile
          fi
        '';
  };
}
