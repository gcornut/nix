{
  pkgs,
  lib,
  getEnv,
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
  ];

  home.sessionPath = [
    "/opt/homebrew/bin"
  ];

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
      MYREPOS = getEnv "MYREPOS";
      XDG_CONFIG_HOME = (getEnv "HOME") + "/.config";
    };

    shellAliases = {
      ":myprs" = toString ./scripts/myprs.js;
      ":pr-submit" = toString ./scripts/pr_submit.sh;
      ":wait-merge" = toString ./scripts/github-watch-merge.js;
      ":wait-deploy" = toString ./scripts/github-watch-deploy.js;
    };

    initContent = mkMerge [
      # Instant prompt first
      (mkBefore (readFile ./p10k.instant-prompt.zsh))
      # Other config after
      (mkAfter (readFile ./zshrc.zsh))
      (mkAfter (readFile ./functions-aliases.zsh))
    ];
  };

  home.file.".p10k.zsh".text = readFile ./p10k.zsh;
}
