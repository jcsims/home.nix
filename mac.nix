{
  config,
  pkgs,
  lib,
  system,
  ...
}: {
  home.packages = with pkgs; [
    terminal-notifier
  ];
}
