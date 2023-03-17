{pkgs, ...}: {
  home.packages = with pkgs; [
    # native comp just spews a ton of errors on mac currently.
    (pkgs.emacs.override {
      nativeComp = false;
    })
    iterm2
    pinentry_mac
    terminal-notifier
  ];
}
