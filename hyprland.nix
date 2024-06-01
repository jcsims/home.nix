{pkgs, ...}: {
  home.packages = with pkgs; [
    _1password-gui
    alacritty
    brave
    calibre
    discord
    kdePackages.dolphin
    maestral
    slack
    spotify
  ];

  # TODO: syncthing setup
  # Though, the base nixos config offers much more, esepcially around
  # pre-configuring the shared folders.

  services.dropbox.enable = true;

  programs.wofi = {
    enable = true;
  };

  wayland.windowManager.hyprland.settings = {
    # Refer to https://wiki.hyprland.org/Configuring/Variables/
    # See https://wiki.hyprland.org/Configuring/Keywords/
    "$mod" = "SUPER";
    "$fileManager" = "dolphin";
    "$menu" = "wofi --show drun";
    "$terminal" = "alacritty";

    # https://wiki.hyprland.org/Configuring/Variables/#animations
    animations = {
      enabled = true;

      # Default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

      bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
      animation = [
        "windows, 1, 7, myBezier"
        "windowsOut, 1, 7, default, popin 80%"
        "border, 1, 10, default"
        "borderangle, 1, 8, default"
        "fade, 1, 7, default"
        "workspaces, 1, 6, default"
      ];
    };

    # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
    bind =
      [
        "$mod, Enter, exec, $terminal"
        ", Print, exec, grimblast copy area"
        "$mod, Q, exec, $terminal"
        "$mod, C, killactive,"
        "$mod, M, exit,"
        "$mod, E, exec, $fileManager"
        "$mod, V, togglefloating,"
        "$mod, R, exec, $menu"
        "$mod, P, pseudo," # dwindle
        "$mod, J, togglesplit," # dwindle

        # Move focus with mod + arrow keys
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        # Example special workspace (scratchpad)
        "$mod, S, togglespecialworkspace, magic"
        "$mod SHIFT, S, movetoworkspace, special:magic"

        # Scroll through existing workspaces with mod + scroll
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"
      ]
      ++ (
        # workspaces
        # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
        builtins.concatLists (builtins.genList (
            x: let
              ws = let
                c = (x + 1) / 10;
              in
                builtins.toString (x + 1 - (c * 10));
            in [
              "$mod, ${ws}, workspace, ${toString (x + 1)}"
              "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
            ]
          )
          10)
      );

    bindm = [
      # Move/resize windows with mod + LMB/RMB and dragging
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];

    # https://wiki.hyprland.org/Configuring/Variables/#decoration
    decoration = {
      rounding = 10;

      # Change transparency of focused and unfocused windows
      active_opacity = "1.0";
      inactive_opacity = "1.0";

      drop_shadow = true;
      shadow_range = 4;
      shadow_render_power = 3;
      col.shadow = "rgba(1a1a1aee)";

      # https://wiki.hyprland.org/Configuring/Variables/#blur
      blur = {
        enabled = true;
        size = 3;
        passes = 1;

        vibrancy = "0.1696";
      };
    };

    # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
    dwindle = {
      # Master switch for pseudotiling. Enabling is bound to mod + P in the
      # keybinds section
      pseudotile = true;
      # You probably want this
      preserve_split = true;
    };

    # See https://wiki.hyprland.org/Configuring/Environment-variables/
    env = [
      "XCURSOR_SIZE,24"
      "HYPRCURSOR_SIZE,24"
    ];

    "exec-once" = [];

    # https://wiki.hyprland.org/Configuring/Variables/#general
    general = {
      gaps_in = 5;
      gaps_out = 20;
      border_size = 2;
      col.active_border = "rgba(33ccffee) rgba(00ff99ee) 45deg";
      col.inactive_border = "rgba(595959aa)";
      # Set to true enable resizing windows by clicking and dragging on borders and gaps
      resize_on_border = false;

      # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
      allow_tearing = false;

      layout = "dwindle";
    };

    # https://wiki.hyprland.org/Configuring/Variables/#gestures
    gestures = {
      workspace_swipe = false;
    };

    # https://wiki.hyprland.org/Configuring/Variables/#input
    input = {
      kb_layout = "us";
      # kb_variant =
      # kb_model =
      kb_options = ["ctrl:nocaps"];
      # kb_rules =
      repeat_rate = 40;
      repeat_delay = 250;

      follow_mouse = 1;

      # -1.0 - 1.0, 0 means no modification.
      sensitivity = 0;

      touchpad = {
        natural_scroll = false;
      };
    };

    # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
    master = {
      new_is_master = true;
    };

    # https://wiki.hyprland.org/Configuring/Variables/#misc
    misc = {
      # Set to 0 or 1 to disable the anime mascot wallpapers
      force_default_wallpaper = -1;
      # If true disables the random hyprland logo / anime girl background. :(
      disable_hyprland_logo = false;
    };

    # See https://wiki.hyprland.org/Configuring/Monitors/
    monitor = ",preferred,auto,2";

    # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
    # See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules
    windowrulev2 = ["suppressevent maximize, class:.*"];
  };

  services.hypridle = {
    enable = true;
    general = {
      after_sleep_cmd = "hyprctl dispatch dpms on";
      ignore_dbus_inhibit = false;
      lock_cmd = "hyprlock";
    };

    listener = [
      {
        timeout = 900;
        on-timeout = "hyprlock";
      }
      {
        timeout = 1200;
        on-timeout = "hyprctl dispatch dpms off";
        on-resume = "hyprctl dispatch dpms on";
      }
    ];
  };

  programs.hyprlock.enable = true;
}
