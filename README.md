# DOTIFILES

## Dipendenze

- stow
- git
- zsh
- fzf
- fd

## Clona la repo con i submodules

```bash
  git clone --recurse-submodules https://github.com/zG4bry/dotfiles.git $HOME/.dotfiles/
```

## Gestione symlinks con stow

```bash
cd $HOME/.dotfiles/
stow */
```

## Aggiornamento submodules

Esegui questo comando nella cartella prinicipale "~/.dotfiles/"

```bash
git submodule update --remote --merge --recursive
```
