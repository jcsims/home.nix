{pkgs}: {
  enable = true;
  shellAbbrs = {
    "ga" = "git add";
    "gc" = "git commit";
    "gco" = "git checkout";
    "gd" = "git diff";
    "gdc" = "git diff --cached";
    "gl" = "git log --graph --abbrev-commit --date=relative --pretty=format:'%C(bold blue)%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'";
    "gp" =  "git push origin HEAD";
    "gpl" =  "git pull --rebase --prune";
    "gs" =  "git status -sb";
    "cat" =  "bat";
    "c" = "pj";
    "co" = "pj open";
  };
  interactiveShellInit = ''
    # Remove the default greeting message on a new shell
    set -g fish_greeting

    # Some prompt color
    set -g hydro_color_prompt green
    set -g hydro_color_pwd blue
    set -g hydro_color_duration yellow

    '';
  shellInit = ''
    # Increase the count of open files allowed (default is 256 on macOS)
    ulimit -Sn 4096

    # Set this here, since I don't want to wrestle with setting this to an array
    # in home-manager.
    set -gx PROJECT_PATHS $HOME/code $HOME/code/work

    # For done notifications, don't notify when it's running emacs from the shell
    set -U --append __done_exclude '^emacsclient'
    '';
  plugins = [
    {
      name = "done";
      src = pkgs.fishPlugins.done.src;
    }
    {
      name = "hydro";
      src = pkgs.fetchFromGitHub {
        owner = "jorgebucaran";
        repo = "hydro";
        rev = "bc31a5ebc687afbfb13f599c9d1cc105040437e1";
        sha256 = "sha256-0MMiM0NRbjZPJLAMDXb+Frgm+du80XpAviPqkwoHjDA=";
      };
    }
    {
      name = "humantime";
      src = pkgs.fetchFromGitHub {
        owner = "jorgebucaran";
        repo = "humantime.fish";
        rev = "1.0.0";
        sha256 = "sha256-FBpQs1ZvNjMXIPAWP4p66EAX+LBtQjhoTHBuU+DtnLM=";
      };
    }
    {
      name = "autopair";
      src = pkgs.fetchFromGitHub {
        owner = "jorgebucaran";
        repo = "autopair.fish";
        rev = "1.0.4";
        sha256 = "sha256-s1o188TlwpUQEN3X5MxUlD/2CFCpEkWu83U9O+wg3VU=";
      };
    }
    {
      name = "pj";
      src = pkgs.fetchFromGitHub {
        owner = "oh-my-fish";
        repo = "plugin-pj";
        rev = "43c94f24fd53a55cb6b01400b9b39eb3b6ed7e4e";
        sha256 = "sha256-/4c/52HLvycTPjuiMKC949XYLPNJUhedd3xEV/ioxfw=";
      };
    }
  ];
}
