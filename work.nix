{
  pkgs,
  lib,
  specialArgs,
  ...
}: let
  hue = specialArgs.extraPackages.hue;
in {
  home.packages =
    (lib.attrValues specialArgs.extraPackages)
    ++ (with pkgs; [
      awscli2
      bazelisk
      nodePackages.typescript-language-server
      phpactor
      terraform
    ]);

  # Stonehenge assumes that bazelisk will be aliased to `bazel` (which the
  # homebrew package does by default).
  home.file."bin/bazel" = {
    text = ''
      #!/usr/bin/env bash

      ${pkgs.bazelisk}/bin/bazelisk "$@"
    '';
    executable = true;
  };

  home.file."bin/set-meeting-light" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      if ${pkgs.coreutils}/bin/timeout 5 ${hue}/bin/hue list > /dev/null; then
          if osascript -e 'tell application "System Events" to get name of (processes where background only is false)' | grep 'zoom.us'; then
              ${hue}/bin/hue '#7'=red,20%
          else
              ${hue}/bin/hue '#7'=off
          fi
      fi
    '';
  };
}
