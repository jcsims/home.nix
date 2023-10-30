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
      etcd_3_5
      google-cloud-sdk # `gcloud` CLI tool
      specialArgs.pkgs-unstable.gopls
      specialArgs.pkgs-unstable.graphite-cli
      grpcurl
      k9s
      kubeconform
      kubectx
      kubelogin
      kustomize
      pipx
      postgresql
      python3Packages.python-lsp-server
      nodejs
      teleport
      nodePackages.sql-formatter
      nodePackages.typescript-language-server
      yq
    ]);

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

  home.sessionPath =
    [
      "$HOME/.local/bin" # pipx install path
      "$HOME/.tiup/bin" # Install path for `tiup`
      "$HOME/code/work/patch/bin" # `dev` tool
    ];
}
