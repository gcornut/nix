# -------------------------------
# ZSH
# -------------------------------

# History > Immediate history append
setopt INC_APPEND_HISTORY

# P10K Prompt
source $NIX_POWERLEVEL10K/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.zsh/p10k.zsh ]] || source ~/.zsh/p10k.zsh
[[ ! -f ~/.zsh/functions-aliases.zsh ]] || source ~/.zsh/functions-aliases.zsh

zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

[[ ! -f ~/.zsh/env.sh ]] || source ~/.zsh/env.sh
