# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

HISTSIZE=5000
SAVEHIST=5000
HISTFILE=~/.zsh_history
setopt appendhistory      # Aggiungi alla storia invece di sovrascrivere
setopt sharehistory       # Condividi la storia tra terminali aperti
setopt inc_append_history # Aggiungi i comandi non appena eseguiti
setopt autocd             # Se scrivi solo una cartella, fai cd dentro (es: 'Desktop' -> cd Desktop)
setopt incappendhistory
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Created by newuser for 5.9
source ~/.zsh-conf/powerlevel10k/powerlevel10k.zsh-theme
autoload -U compinit
compinit

source ~/.zsh-conf/completion.zsh
source ~/.zsh-conf/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh-conf/key-bindings.zsh
source ~/.zsh-conf/colored-man-pages.plugin.zsh

alias ls='ls --color=auto'
alias la='ls -lah'

bindkey -e
# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)
source ~/.zsh-conf/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh