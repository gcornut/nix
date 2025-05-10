{ pkgs, getEnv, ... }: {
  home.packages = with pkgs; [
    git
    github-cli
    graphite-cli
  ];

  programs.gh = {
    enable = true;
    extensions = [
      pkgs.gh-markdown-preview
      pkgs.gh-poi
    ];
    settings = {
      git_protocol = "ssh";
      editor = "vim";
    };
  };

  programs.git = {
    enable = true;
    userName = getEnv "GIT_USERNAME";
    userEmail = getEnv "GIT_USEREMAIL";

    lfs.enable = true;

    delta.enable = true;

    maintenance.enable = true;

    ignores = [
      ".DS_Store"
      "*.log"
      "nohup.out"
      ".idea"
      ".zed"
      ".nix"
      ".eslintcache"
    ];
    extraConfig = {
      core = {
        ignorecase = false;
        whitespace = "-trailing-space";
      };
      fetch.prune = true;
      submodule.recurse = true;
      pull.rebase = true;
      push.autoSetupRemote = true;
      rebase.autosquash = true;
      rerere.enabled = true;
      color.ui = "auto";
    };

    aliases = {
      fetch-clean = "!git fetch --prune && git fetch origin";

      pl = "pull";
      plhard = "!git fetch origin $(git rev-parse --abbrev-ref HEAD) && git rhard origin/$(git rev-parse --abbrev-ref HEAD)";

      rhard = "reset --hard";

      st = "status -sb";
	    ch = "!${./scripts/git_checkout.sh}";

	    cm = "commit -m";
	    amend = "commit --amend --reuse-message=HEAD";

	    ps = "push";
	    psf = "push --force-with-lease";

	    l = "log --pretty=oneline -n 20 --graph --abbrev-commit";
	    ll = "!git log --graph --pretty=format:'%Cred%h%Creset - %C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an %ae>%Creset' --abbrev-commit --date=relative";
    };
  };
}
