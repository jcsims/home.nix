{
  config,
  pkgs,
  lib,
  system,
  ...
}: {
  home.packages = with pkgs; [];
}
