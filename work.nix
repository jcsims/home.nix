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
      awscli2
      bazelisk
      nodePackages.intelephense
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
}
