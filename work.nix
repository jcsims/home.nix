{
  pkgs,
  lib,
  specialArgs,
  ...
}: let
  hue = specialArgs.extraPackages.hue;

  set-meeting-light = pkgs.writeShellScript "set-meeting-light.sh" ''
    if ${pkgs.coreutils}/bin/timeout 5 ${hue}/bin/hue list > /dev/null; then
      if osascript -e 'tell application "System Events" to get name of (processes where background only is false)' | grep 'zoom.us' > /dev/null 2>&1 ; then
        ${hue}/bin/hue '#7'=red,20%
      else
        ${hue}/bin/hue '#7'=off
      fi
    fi
  '';
in {
  home.packages =
    (lib.attrValues specialArgs.extraPackages)
    ++ (with pkgs; [
      awscli2
      bazelisk
      nodePackages.typescript-language-server
      php
      phpactor
      python310
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

  launchd.agents.set-meeting-light = {
    enable = true;
    config = {
      Program = "${set-meeting-light}";
      ProcessType = "Background";
      StartCalendarInterval = [{}];
      StandardOutPath = "/tmp/set-meeting-light-out.log";
      StandardErrorPath = "/tmp/set-meeting-light-err.log";
    };
  };
}
