{
  pkgs,
  lib,
  specialArgs,
  ...
}:
{
  home.packages =
    (lib.attrValues specialArgs.extraPackages)
    ++ (with pkgs; [
      _1password-gui
      alacritty
      calibre
      discord
      slack
      spotify
    ]);

  home.sessionVariables = {
    STEAM_FORCE_DESKTOPUI_SCALING = "2";
  };

  services.syncthing = {
    enable = true;
    tray.enable = true;
  };

  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = [ "graphical-session-pre.target" ];
    };
  };

  # KDE Plasma config
  programs.plasma = {
    enable = true;

    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
    };

    shortcuts = {
      ksmserver."Lock Session" = [ "Meta+Alt+L" ];
      kwin = {
        ExposeAll = [ "Meta+Ctrl+Alt+Up" ];
        "Walk Through Windows" = "Meta+Tab";
        "Walk Through Windows (Reverse)" = "Meta+Shift+Tab";
        "Walk Through Windows of Current Application" = "Meta+`";
        "Walk Through Windows of Current Application (Reverse)" = "Meta+~";
        "Window Maximize" = [ "Ctrl+Alt+Return" ];
        "Window Minimize" = [ "Meta+H" ];
        "Window Quick Tile Bottom" = "Ctrl+Alt+Down";
        "Window Quick Tile Left" = "Ctrl+Alt+Left";
        "Window Quick Tile Right" = "Ctrl+Alt+Right";
        "Window Quick Tile Top" = "Ctrl+Alt+Up";
      };
      org_kde_powerdevil = {
        # Same keys for brightness as in macOS
        "Decrease Screen Brightness" = [
          "Monitor Brightness Down"
          "ScrollLock"
        ];
        "Increase Screen Brightness" = [
          "Monitor Brightness Up"
          "Pause"
        ];
      };
      plasmashell = {
        "show dashboard" = [
          "Meta+Ctrl+Alt+Down"
          "Ctrl+F12"
        ];
      };
      "services/org.kde.krunner.desktop"."_launch" = [
        "Meta+Space"
        "Search"
        "Alt+F2"
      ];
    };

    configFile = {
      # Swap alt and win for the Sculpt keyboard, and remap caps to ctrl
      kxkbrc.Layout.Options = "altwin:swap_alt_win,caps:ctrl_modifier";

      # Set keyboard repeat rate and delay
      kcminputrc.Keyboard.RepeatDelay = 250;
      kcminputrc.Keyboard.RepeatRate = 40;

      # Try to emulate some keybindings from Emacs. These are produced by rc2nix
      # by: nix run github:pjones/plasma-manager
      "kdeglobals"."Shortcuts"."Activate Next Tab" = "Ctrl+PgDown; Ctrl+]; Meta+Alt+Right";
      "kdeglobals"."Shortcuts"."Activate Previous Tab" = "Meta+Alt+Left; Ctrl+[; Ctrl+PgUp";
      "kdeglobals"."Shortcuts"."Back" = "Meta+Left; Back";
      "kdeglobals"."Shortcuts"."BackwardWord" = "Ctrl+Left; Alt+Left";
      "kdeglobals"."Shortcuts"."BeginningOfLine" = "Ctrl+A; Home";
      "kdeglobals"."Shortcuts"."Copy" = "Ctrl+C; Meta+C; Ctrl+Ins";
      "kdeglobals"."Shortcuts"."Cut" = "Ctrl+X; Shift+Del; Meta+X";
      "kdeglobals"."Shortcuts"."DeleteWordBack" = "Ctrl+Backspace; Alt+Backspace";
      "kdeglobals"."Shortcuts"."EndOfLine" = "End; Ctrl+E";
      "kdeglobals"."Shortcuts"."Find" = "Meta+F; Ctrl+F";
      "kdeglobals"."Shortcuts"."Forward" = "Forward; Meta+Right";
      "kdeglobals"."Shortcuts"."ForwardWord" = "Ctrl+Right; Alt+Right";
      "kdeglobals"."Shortcuts"."Open" = "Meta+O; Ctrl+O";
      "kdeglobals"."Shortcuts"."Paste" = "Meta+V; Ctrl+V; Shift+Ins";
      "kdeglobals"."Shortcuts"."Preferences" = "Meta+,; Ctrl+Shift+,";
      "kdeglobals"."Shortcuts"."Print" = "Meta+P; Ctrl+P";
      "kdeglobals"."Shortcuts"."Quit" = "Meta+Q; Ctrl+Q";
      "kdeglobals"."Shortcuts"."Reload" = "F5; Refresh; Meta+R";
      "kdeglobals"."Shortcuts"."Save" = "Ctrl+S; Meta+S";
      "kdeglobals"."Shortcuts"."SelectAll" = "Meta+A";
      "kdeglobals"."Shortcuts"."TextCompletion" = "";
      "kdeglobals"."Shortcuts"."Undo" = "Meta+Z; Ctrl+Z";

      # Set up clipboard history
      "klipperrc"."General"."IgnoreImages" = false;
      "klipperrc"."General"."IgnoreSelection" = false;
      "klipperrc"."General"."MaxClipItems" = 2000;
      # Sync selection and clipboard
      "klipperrc"."General"."SyncClipboards" = true;
    };
  };
}
