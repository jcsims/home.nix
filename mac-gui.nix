{pkgs, specialArgs, ...}: {
  home.packages = with pkgs; [
    specialArgs.unstable_pkgs.emacs
    iterm2
    specialArgs.unstable_pkgs.neovim
    pinentry_mac
    terminal-notifier
  ];
}
