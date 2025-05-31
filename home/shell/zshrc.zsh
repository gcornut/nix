# -------------------------------
# ZSH
# -------------------------------

# History > Immediate history append
setopt INC_APPEND_HISTORY

# P10K Prompt
source $NIX_POWERLEVEL10K/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
