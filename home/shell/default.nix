{
  pkgs,
  lib,
  globals,
  env,
  mkDotfileLinks,
  config,
  ...
}:
with lib;
with builtins; {
  home.packages = with pkgs; [
    bash
    zsh
    zsh-powerlevel10k

    # tools
    coreutils
    gnused
    jq
    eza
    dos2unix
    fzf
    moreutils
    htop
  ];

  home.sessionPath = [
    "/opt/homebrew/bin"
  ];

  home.file = mkDotfileLinks config {
    from = ./zsh;
    to = ".zsh";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autosuggestion = {
      enable = true;
      strategy = ["match_prev_cmd" "history"];
    };
    history = {
      save = 1000000000;
      size = 1000000000;
      append = true;
      share = true;
      ignoreSpace = true;
      ignoreAllDups = true;
      ignoreDups = true;
      saveNoDups = true;
      findNoDups = true;
      expireDuplicatesFirst = true;
    };

    historySubstringSearch.enable = true;

    sessionVariables = {
      EDITOR = "vim";
      NIX_POWERLEVEL10K = pkgs.zsh-powerlevel10k;
      MYREPOS = env.MYREPOS;
      XDG_CONFIG_HOME = globals.home + "/.config";
    };

    shellAliases = {
      ":myprs" = "~/.zsh/scripts/myprs.js";
      ":pr-submit" = "~/.zsh/scripts/pr_submit.sh";
      ":wait-merge" = "~/.zsh/scripts/github-watch-merge.js";
      ":wait-deploy" = "~/.zsh/scripts/github-watch-deploy.js";
    };

    initContent = mkMerge [
      # Instant prompt first
      (mkBefore (readFile ./zshrc/before.zsh))
      # Other config after
      (mkAfter (readFile ./zshrc/after.zsh))
    ];
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
