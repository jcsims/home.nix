{
  pkgs,
  lib,
  system,
  specialArgs,
  ...
}: let
  appliance-config = (import (builtins.fetchGit {
    url = "git@github.threatbuild.com:threatgrid/appliance.git";
    rev = "5c570e63d0f869c2b2689f8ff6418775a5c545b2";
  })) {system = system;};

  hue = specialArgs.extraPackages.hue;
in rec {
  home.username = "chrsims";
  home.homeDirectory = "/Users/chrsims";

  home.packages =
    (lib.attrValues specialArgs.extraPackages)
    ++ [
      appliance-config.dev-tools-build
      appliance-config.dev-tools-automation
      appliance-config.tgRash
    ]
    ++ (with pkgs; [
      act
      actionlint
      elasticsearch7
      go
      go-bindata
      gopls
      postgresql_13
      python310Packages.jedi-language-server
      redis
    ]);

  home.file."bin/set-meeting-light" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      if ${pkgs.coreutils}/bin/timeout 5 ${hue}/bin/hue list > /dev/null; then
          if osascript -e 'tell application "System Events" to get name of (processes where background only is false)' | grep 'Meeting Center'; then
              ${hue}/bin/hue '#7'=red,20%
          else
              ${hue}/bin/hue '#7'=off
          fi
      fi
    '';
  };
}
