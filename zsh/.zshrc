# --- Configurazione history ---
HISTSIZE=50000
SAVEHIST=50000
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

# --- Inizializzazione Keymap (Emacs) e Stile Selezione ---
bindkey -e
zle_highlight=(region:bg=4,fg=15)  # Evidenziazione visiva della selezione (regione)

# --- Configurazione Cache ---
export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[[ -d "$ZSH_CACHE_DIR" ]] || mkdir -p "$ZSH_CACHE_DIR"

# --- Inizializzazione tema e completamento ---
autoload -U compinit; compinit
autoload -U colors; colors
# --- Caricamento plugins ---
# Syntax Highlighting va in fondo
source ~/.zsh-conf/fzf-tab/fzf-tab.plugin.zsh
source ~/.zsh-conf/completion.zsh
source ~/.zsh-conf/zsh-shift-select/zsh-shift-select.plugin.zsh
source ~/.zsh-conf/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh-conf/key-bindings.zsh
source ~/.zsh-conf/colored-man-pages.plugin.zsh

# --- Alias ---
# Usa eza se disponibile, altrimenti ls
if command -v eza &> /dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -l --icons --group-directories-first --git --header'
    alias la='eza -a --icons --group-directories-first --git'
    alias lla='eza -la --icons --git --group-directories-first --header'    # Vista ad albero (sostituto moderno del comando tree)
    alias lt='eza --tree --level=2 --icons --group-directories-first'

else
    alias ls='ls --color=auto'
    alias la='ls -lAh --color=auto'
fi

# Crea alias solo se ti trovi su ubuntu
# fd: Debian/Ubuntu espongono il comando come fdfind
if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
    alias fd='fdfind'
    FZF_FD_COMMAND='fdfind'
else
    FZF_FD_COMMAND='fd'
fi

# --- Configurazione FZF ---
# Configurazione CTRL-T, ALT-C

#export FZF_DEFAULT_COMMAND='find . -maxdepth 4 -not -path "*/.*"'
export FZF_DEFAULT_COMMAND="$FZF_FD_COMMAND --strip-cwd-prefix --hidden --follow"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="$FZF_FD_COMMAND --type d --strip-cwd-prefix --hidden --follow --exclude .git"
#export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --info=inline'

# Stile FZF (Bordi arrotondati e caratteri sicuri)
export FZF_DEFAULT_OPTS=" \
--height 50% \
--layout=reverse \
--info=inline \
--border=rounded \
--pointer='> ' \
--marker='* ' \
--preview-window=right:50%:wrap \
--bind 'alt-p:toggle-preview' \
--bind 'ctrl-up:preview-up,ctrl-down:preview-down'"

# Anteprima per CTRL-T (usa eza/bat se disponibili, altrimenti ls/cat)
export FZF_CTRL_T_OPTS="
  --preview 'if [ -d {} ]; then
      command -v eza &> /dev/null && eza -lh --icons --color=always {} || ls -lAFh --color=always {};
  else
      command -v bat &> /dev/null && bat -n --color=always --line-range :500 {} || \
      command -v batcat &> /dev/null && batcat -n --color=always --line-range :500 {} || \
      cat {};
  fi'"

# Anteprima per ALT-C (usa eza se disponibile, altrimenti ls)
export FZF_ALT_C_OPTS="--preview 'command -v eza &> /dev/null && eza -lh --icons --color=always {} || ls -lAFh --color=always {}'"
source <(fzf --zsh)

# --- Configurazione FZF-TAB ---

# Disabilita il menu di zsh standard
zstyle ':completion:*' menu no
# Unisce i gruppi (file, directory, ecc.) in un unico elenco
#zstyle ':completion:*' group-name ''
# Usa i colori di sistema (LS_COLORS) per i completamenti
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# Forza l'uso di fd per cercare i file
zstyle ':fzf-tab:complete:*:*files*' fzf-completion-file-finder $FZF_DEFAULT_COMMAND
# Configurazione finestra fzf-tab
zstyle ':fzf-tab:*' fzf-flags \
                            --height=50% \
                            --layout=reverse \
                            --border=rounded \
                            --preview-window='right:50%:wrap' \
                            --bind='alt-p:toggle-preview' \
                            --bind='ctrl-up:preview-up,ctrl-down:preview-down'

# 1. Preview per variabili d'ambiente
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
    fzf-preview 'echo ${(P)word}'
# 2. Preview GENERALE intelligente (File vs Directory vs Altro)
zstyle ':fzf-tab:complete:*:*' fzf-preview '
  # Usa $realpath se disponibile, altrimenti usa $word
  local target=${realpath:-$word}

  if [ -d "$target" ]; then
     # È una directory: usa eza se disponibile, altrimenti ls
     command -v eza &> /dev/null && eza -lh --icons --color=always "$target" || ls -lAFh --color=always "$target"
  elif [ -f "$target" ]; then
     # È un file: usa bat o batcat se disponibili, altrimenti cat
     if command -v bat &> /dev/null; then
         bat --color=always --style=numbers --line-range :500 "$target"
     elif command -v batcat &> /dev/null; then
         batcat --color=always --style=numbers --line-range :500 "$target"
     else
         cat "$target"
     fi
  else
     # Non è né file né cartella (flag, comandi, etc): Pulisci la preview
     echo " "
  fi'

# 5. Preview per Processi (comando kill)
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':fzf-tab:complete:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':fzf-tab:complete:*:*:kill:*:processes' fzf-preview 'ps --pid=$word -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:*:*:kill:*:processes' fzf-flags --preview-window=down:3:wrap

# 4. Preview per git checkout / switch (mostra log del branch)
zstyle ':fzf-tab:complete:git-(checkout|switch):*' fzf-preview \
    'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $word'

# 5. Preview per git diff / add (mostra le differenze del file)
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview \
	'git diff $word --color=always'

source ~/.zsh-conf/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Added by Antigravity CLI installer
export PATH="/home/gab/.local/bin:$PATH"

eval "$(starship init zsh)"

# opencode
export PATH=/home/gab/.opencode/bin:$PATH
