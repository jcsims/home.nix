{ pkgs, ... }:
{
  programs.alacritty = {
    enable = true;
    settings = {
      # Colors from
      # https://github.com/alacritty/alacritty-theme/blob/master/themes/snazzy.toml
      colors.bright = {
        black = "#686868";
        red = "#ff5c57";
        green = "#5af78e";
        yellow = "#f3f99d";
        blue = "#57c7ff";
        magenta = "#ff6ac1";
        cyan = "#9aedfe";
        white = "#f1f1f0";
      };
      colors.normal = {
        black = "#282a36";
        red = "#ff5c57";
        green = "#5af78e";
        yellow = "#f3f99d";
        blue = "#57c7ff";
        magenta = "#ff6ac1";
        cyan = "#9aedfe";
        white = "#f1f1f0";
      };
      colors.primary = {
        background = "#282a36";
        foreground = "#eff0eb";
      };
      # To get the font not so bold on macOS, run this:
      # `defaults write org.alacritty AppleFontSmoothing -int 0`
      font = {
        size = 12;
        bold.family = "Hack Nerd Font";
        bold_italic.family = "Hack Nerd Font";
        italic.family = "Hack Nerd Font";
        normal.family = "Hack Nerd Font";
      };
      keyboard.bindings = [
        {
          action = "ClearHistory";
          key = "L";
          mode = "~Vi|~Search";
          mods = "Control";
        }
        {
          action = "ScrollPageUp";
          key = "PageUp";
          mode = "~Alt";
          mods = "Shift";
        }

        {
          action = "ScrollPageDown";
          key = "PageDown";
          mode = "~Alt";
          mods = "Shift";
        }

        {
          action = "SearchConfirm";
          key = "Return";
          mode = "Search|Vi";
        }
        {
          action = "SearchCancel";
          key = "Escape";
          mode = "Search";
        }
        {
          action = "SearchCancel";
          key = "C";
          mode = "Search";
          mods = "Control";
        }

        {
          action = "SearchClear";
          key = "U";
          mode = "Search";
          mods = "Control";
        }

        {
          action = "SearchDeleteWord";
          key = "W";
          mode = "Search";
          mods = "Control";
        }

        {
          action = "SearchHistoryPrevious";
          key = "P";
          mode = "Search";
          mods = "Control";
        }

        {
          action = "SearchHistoryNext";
          key = "N";
          mode = "Search";
          mods = "Control";
        }

        {
          action = "SearchHistoryPrevious";
          key = "Up";
          mode = "Search";
        }
        {
          action = "SearchHistoryNext";
          key = "Down";
          mode = "Search";
        }
        {
          action = "SearchFocusNext";
          key = "Return";
          mode = "Search|~Vi";
        }
        {
          action = "SearchFocusPrevious";
          key = "Return";
          mode = "Search|~Vi";
          mods = "Shift";
        }

        {
          chars = "\\f";
          key = "K";
          mode = "~Vi|~Search";
          mods = "Command";
        }

        {
          action = "ClearHistory";
          key = "K";
          mode = "~Vi|~Search";
          mods = "Command";
        }

        {
          action = "ResetFontSize";
          key = "Key0";
          mods = "Command";
        }
        {
          action = "IncreaseFontSize";
          key = "Equals";
          mods = "Command";
        }
        {
          action = "IncreaseFontSize";
          key = "Plus";
          mods = "Command";
        }
        {
          action = "IncreaseFontSize";
          key = "NumpadAdd";
          mods = "Command";
        }
        {
          action = "DecreaseFontSize";
          key = "Minus";
          mods = "Command";
        }
        {
          action = "DecreaseFontSize";
          key = "NumpadSubtract";
          mods = "Command";
        }
        {
          action = "Paste";
          key = "V";
          mods = "Command";
        }
        {
          action = "Copy";
          key = "C";
          mods = "Command";
        }
        {
          action = "ClearSelection";
          key = "C";
          mode = "Vi|~Search";
          mods = "Command";
        }

        {
          action = "Hide";
          key = "H";
          mods = "Command";
        }
        {
          action = "HideOtherApplications";
          key = "H";
          mods = "Command|Alt";
        }
        {
          action = "Minimize";
          key = "M";
          mods = "Command";
        }
        {
          action = "Quit";
          key = "Q";
          mods = "Command";
        }
        {
          action = "Quit";
          key = "W";
          mods = "Command";
        }
        {
          action = "CreateNewWindow";
          key = "N";
          mods = "Command";
        }
        {
          action = "ToggleFullscreen";
          key = "F";
          mods = "Command|Control";
        }
        {
          action = "SearchForward";
          key = "F";
          mode = "~Search";
          mods = "Command";
        }

        {
          action = "SearchBackward";
          key = "B";
          mode = "~Search";
          mods = "Command";
        }

        {
          action = "CreateNewTab";
          key = "T";
          mods = "Command";
        }
        {
          action = "SelectPreviousTab";
          key = "Left";
          mods = "Command";
        }
        {
          action = "SelectNextTab";
          key = "Right";
          mods = "Command";
        }
      ];
      mouse.bindings = [
        {
          action = "PasteSelection";
          mode = "~Vi";
          mouse = "Middle";
        }
      ];
      scrolling.history = 20000;
      selection.save_to_clipboard = true;
      shell = {
        program = "${pkgs.fish}/bin/fish";
        args = [ "--login" ];
      };
      window = {
        dynamic_padding = true;
        option_as_alt = "OnlyLeft";
        padding.x = 2;
        padding.y = 2;
        startup_mode = "Windowed";
      };
    };
  };
}
