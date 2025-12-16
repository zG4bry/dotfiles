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

# ☁️ Montaggio Automatico di OneDrive (Rclone + Systemd User Service)

Questa guida spiega come configurare un servizio Systemd in modalità utente per montare automaticamente il tuo account OneDrive all'avvio del sistema, utilizzando `rclone`. Questo è il metodo più robusto per l'integrazione desktop su Linux.

**Parametri utilizzati in questa configurazione:**
* **Nome del Remote configurato in rclone:** `onedrive`
* **Cartella di Montaggio Locale:** `~/OneDrive`

---

## 1. Prerequisiti

1.  **Rclone Installato:** Assicurati che `rclone` sia installato sul sistema.
    *Esempio per Fedora:* `sudo dnf install rclone`
2.  **Remote Configurato:** Devi aver già configurato il remote di rclone con il nome esatto **`onedrive`** (usando il comando `rclone config`).
3.  **Sistema:** Linux con **Systemd** (es. Fedora, Ubuntu, Debian, Arch, ecc.).

---

## 2. Preparazione dell'Ambiente e del File di Servizio

Apri il terminale ed esegui i comandi per creare le cartelle necessarie e il file di servizio Systemd.

### A. Preparazione Cartelle

```bash
# 1. Crea la cartella locale dove appariranno i file di OneDrive
mkdir -p ~/OneDrive

# 2. Crea la directory necessaria per i servizi utente di Systemd
mkdir -p ~/.config/systemd/user
```

 ### B. Creazione del File di Servizio
 Utilizza **`nano`** (o il tuo editor preferito) per creare il file:

 ```bash
 nano ~/.config/systemd/user/rclone-onedrive.service
 ```

 Copia e incolla il seguente blocco di testo nel file. I flag sono ottimizzati per la stabilità desktop e la gestione dello spazio.

```bash
[Unit]
Description=Rclone Mount per OneDrive
Documentation=[http://rclone.org/docs/](http://rclone.org/docs/)
# Assicura che il servizio parta dopo che la rete è attiva
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
# Comando per l'avvio del mount di rclone. %h viene sostituito con la home directory dell'utente.
ExecStart=/usr/bin/rclone mount onedrive: %h/OneDrive \
    --vfs-cache-mode full \
    --vfs-cache-max-age 24h \
    --vfs-cache-max-size 50G \
    --log-level INFO \
    --log-file %h/.cache/rclone-mount.log

# Comando di stop per uno smontaggio pulito
ExecStop=/usr/bin/fusermount -u %h/OneDrive

# Riavvia il servizio se dovesse terminare con un errore
Restart=on-failure
RestartSec=10s

[Install]
# Avvia il servizio automaticamente quando l'utente esegue il login
WantedBy=default.target
```

Salva e chiudi l'editor (`Ctrl+O`, `Invio`, `Ctrl+X` in Nano).

---

# 3. Spiegazione dei Flag Essenziali di Montaggio (`ExecStart`)

Questi flag sono fondamentali per la stabilità e la gestione dello spazio in un ambiente desktop:

---

|Flag|Descrizione|Vantaggio per l'Uso Desktop|
|---|---|---|
|`--vfs-cache-mode full`|Abilita la cache VFS (Virtual File System) in modalità completa.|**Massima Stabilità:** Essenziale affinché i programmi desktop (editor, uffici, ecc.) possano modificare i file senza problemi di I/O, scaricando l'intero file localmente prima dell'uso.|
|`--vfs-cache-max-age 24h`|Elimina i file dalla cache se non vengono utilizzati per più di 24 ore.|**Gestione Spazio:** Previene che la cache locale (`~/.cache/rclone/vfs`) cresca all'infinito, liberando spazio su disco dai file non più utilizzati.|
|`--log-level INFO / --log-file`|Controlla il livello di dettaglio dei messaggi e li indirizza a un file di log.|**Monitoraggio Facile:** Utile per diagnosticare problemi senza dover analizzare i log di sistema completi.|
---
# 4. Avvio e Abilitazione del Servizio
Esegui questi comandi per rendere il servizio operativo e autoamatico:

|Comando|Descrizione|
|---|---|
|`systemctl --user daemon-reload`|Ricarica la configurazione di Systemd per riconoscere il nuovo file di servizio.|
|`systemctl --user enable rclone-onedrive.service`|Abilita l'avvio automatico al prossimo login utente (rende il mount persistente).|
|`systemctl --user start rclone-onedrive.service`|Avvia il servizio immediatamente (monta OneDrive ora, senza riavviare).|
|`systemctl --user status rclone-onedrive.service`|Verifica che lo stato sia `active (running)` e non ci siano errori.|
---
# 5. Gestione del Servizio (Comandi Utili)

Questi comandi consentono di controllare il servizio Systemd in qualsiasi momento:

|Azione|Comando|
|---|---|
|Smontare (Fermare)|`systemctl --user stop rclone-onedrive.service`|
|Riavviare (Se si blocca)|`systemctl --user restart rclone-onedrive.service`|
|Disattivare Auto-Avvio|`systemctl --user disable rclone-onedrive.service`|
|Visualizza Log Dettagliati|`journalctl --user -xeu rclone-onedrive.service`|
