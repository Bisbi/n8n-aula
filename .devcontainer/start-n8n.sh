#!/usr/bin/env bash
# Avvia n8n in background con gli indirizzi giusti per GitHub Codespaces.
#   bash .devcontainer/start-n8n.sh           avvia (se non è già acceso)
#   bash .devcontainer/start-n8n.sh restart   spegne e riavvia
#   bash .devcontainer/start-n8n.sh stop      spegne
#   bash .devcontainer/start-n8n.sh reset     cancella l'account (password dimenticata), i flussi restano
set -euo pipefail

PORT=5678

# I dati (flussi, credenziali) e il log vanno in /workspaces: sopravvive anche
# al "Rebuild" del container ed è fuori dalla cartella del repository.
if [ -w /workspaces ]; then
  export N8N_USER_FOLDER=/workspaces
fi
DATA="${N8N_USER_FOLDER:-$HOME}"
LOG="$DATA/n8n.log"
PIDFILE="$DATA/n8n.pid"

# Nome del Codespace: dalla variabile, oppure dal file che Codespaces lascia
# nel container (la variabile manca nelle sessioni "gh codespace ssh").
CS_ENV=/workspaces/.codespaces/shared/environment-variables.json
if [ -z "${CODESPACE_NAME:-}" ] && [ -f "$CS_ENV" ]; then
  CODESPACE_NAME=$(node -p "require('$CS_ENV').CODESPACE_NAME || ''")
fi

# Dentro Codespaces l'indirizzo pubblico è <nome-codespace>-5678.<dominio>.
# Serve a n8n per costruire i link dell'editor e dei webhook.
if [ -n "${CODESPACE_NAME:-}" ]; then
  HOST="${CODESPACE_NAME}-${PORT}.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-app.github.dev}"
  export N8N_PROTOCOL=https
  export N8N_HOST="$HOST"
  export N8N_EDITOR_BASE_URL="https://$HOST/"
  export WEBHOOK_URL="https://$HOST/"
  # Il proxy di Codespaces è un passaggio intermedio.
  export N8N_PROXY_HOPS=1
fi

# Aggiornamenti dell'editor via SSE invece di WebSocket: dietro il proxy di
# Codespaces il WebSocket fallisce con "Origin header does NOT match".
export N8N_PUSH_BACKEND=sse

export N8N_PORT=$PORT
export N8N_LISTEN_ADDRESS=0.0.0.0
export GENERIC_TIMEZONE=Europe/Rome
export N8N_DIAGNOSTICS_ENABLED=false
export N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true

is_running() {
  [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null
}

stop_n8n() {
  if is_running; then
    kill "$(cat "$PIDFILE")"
    sleep 3
  fi
  rm -f "$PIDFILE"
}

if ! command -v n8n >/dev/null; then
  echo "n8n non è installato. Esegui: npm install -g n8n@2.43.8"
  exit 1
fi

case "${1:-start}" in
  stop) stop_n8n; echo "n8n spento."; exit 0 ;;
  restart) stop_n8n ;;
  reset)
    stop_n8n
    n8n user-management:reset
    echo "Account cancellato: riavvio n8n, poi ricrea l'account dalla pagina di n8n."
    ;;
esac

if is_running; then
  echo "n8n è già acceso. Log: tail -f $LOG"
  exit 0
fi

setsid nohup n8n start >>"$LOG" 2>&1 </dev/null &
echo $! >"$PIDFILE"
disown

echo "n8n in avvio (circa 30 secondi). Log: tail -f $LOG"
if [ -n "${HOST:-}" ]; then
  echo "Indirizzo: https://$HOST/"
else
  echo "Indirizzo: http://localhost:$PORT/"
fi
