{ pkgs
, lib
, system
, specialArgs
, ...
}:
let
  hue = specialArgs.extraPackages.hue;
in
rec {
  home.packages =
    (lib.attrValues specialArgs.extraPackages)
    ++ (with pkgs; [
      apacheKafka
      azure-cli
      babashka
      clojure
      etcd_3_5
      google-cloud-sdk # `gcloud` CLI tool
      go
      graphite-cli
      kubectl
      kubelogin
      pipx
      python3Packages.python-lsp-server
      sops
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
