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
#setopt incappendhistory
setopt hist_ignore_all_dups
#setopt hist_save_no_dups
#setopt hist_ignore_dups
#setopt hist_find_no_dups
setopt hist_reduce_blanks
setopt autocd             # Se scrivi solo una cartella, fai cd dentro (es: 'Desktop' -> cd Desktop)

# Created by newuser for 5.9
source ~/.zsh-conf/powerlevel10k/powerlevel10k.zsh-theme
autoload -U compinit; compinit

source ~/.zsh-conf/fzf-tab/fzf-tab.plugin.zsh
source ~/.zsh-conf/completion.zsh
source ~/.zsh-conf/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh-conf/key-bindings.zsh
source ~/.zsh-conf/colored-man-pages.plugin.zsh

# Usa eza se disponibile, altrimenti ls
if command -v eza &> /dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -l --icons --group-directories-first --git'
    alias la='eza -la --icons --group-directories-first --git'
    alias tree='eza --tree --icons'
else
    alias ls='ls --color=auto'
    alias la='ls -lah'
fi
# Configurazione FZF
#export FZF_DEFAULT_COMMAND='find . -maxdepth 4 -not -path "*/.*"'
export FZF_DEFAULT_COMMAND='fd --strip-cwd-prefix --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --strip-cwd-prefix --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --info=inline'

export FZF_CTRL_T_OPTS="
  --preview 'if [ -d {} ]; then 
      ls -F --color=always {}; 
  else 
      bat -n --color=always --line-range :500 {}; 
  fi'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

export FZF_ALT_C_OPTS="--preview 'ls -F --color=always {}'"
source <(fzf --zsh)

# Configurazione FZF-TAB
zstyle ':completion:*' menu no
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
#zstyle ':fzf-tab:complete:*:*files*' fzf-completion-file-finder $FZF_DEFAULT_COMMAND
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
	fzf-preview 'echo ${(P)word}'
# Non mostrare nulla (output vuoto) quando si completano i flag
zstyle ':fzf-tab:complete:*:*:-option-:*' fzf-preview 'echo ""'
zstyle ':fzf-tab:complete:*:*:-long-option-:*' fzf-preview 'echo ""'
zstyle ':fzf-tab:complete:*:*' fzf-preview '
  if [ -d $realpath ]; then
     ls -F --color=always $realpath
  else
     bat --color=always --style=numbers --line-range :500 $realpath
  fi'
zstyle ':fzf-tab:*' fzf-flags --height=40% --layout=reverse 

source ~/.zsh-conf/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

bindkey -e

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh