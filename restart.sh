#!/usr/bin/env bash
set -Eeuo pipefail

SERVICE="canary_server"
OUT_LOG="logs/canary_server_out.log"
ERR_LOG="logs/canary_server_err.log"
TAIL_LINES=120
FOLLOW_TAIL=1
CLEAR_BEFORE=1
RETRIES=1
DELAY=2
SHOW_ONLY_ERRORS=0
AUTO_DETECT_SERVICE=1

usage() {
  cat <<'USAGE'
Uso:
  ./restart.sh [opcoes]

Opcoes:
  -s, --service NOME        Nome do programa/grupo no supervisor (padrao: canary_server)
  -o, --out-log CAMINHO     Log de saida (padrao: logs/canary_server_out.log)
  -e, --err-log CAMINHO     Log de erro (padrao: logs/canary_server_err.log)
  -n, --lines NUM           Linhas no tail (padrao: 120)
  -r, --retries NUM         Quantidade de restarts (padrao: 1)
  -d, --delay SEG           Espera entre restarts em segundos (padrao: 2)
      --no-follow           Mostra tail sem seguir
      --no-clear            Nao limpa logs antes de cada restart
      --errors              So lista servicos em erro no supervisor e sai
      --no-auto-service     Nao tenta descobrir nome alternativo no Supervisor
  -h, --help                Mostra ajuda

Exemplos:
  ./restart.sh
  ./restart.sh -r 3 -d 4
  ./restart.sh -s canary:* -n 200
  ./restart.sh --errors
USAGE
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "[erro] comando nao encontrado: $1" >&2
    exit 1
  }
}

run_supervisorctl() {
  # Tenta sem sudo primeiro; se falhar, usa sudo.
  if supervisorctl "$@" >/dev/null 2>&1; then
    supervisorctl "$@"
    return 0
  fi
  sudo supervisorctl "$@"
}

get_status() {
  if supervisorctl status >/dev/null 2>&1; then
    supervisorctl status
  else
    sudo supervisorctl status
  fi
}

print_error_services() {
  local st
  st="$(get_status)"
  echo "$st" | awk '$2 ~ /FATAL|BACKOFF|EXITED|STOPPED/ {print}'
}

service_exists() {
  local target="$1"
  local st
  st="$(get_status || true)"
  [[ -n "$st" ]] || return 1
  echo "$st" | awk -v s="$target" '$1 == s { found=1 } END { exit(found ? 0 : 1) }'
}

find_canary_candidates() {
  local st
  st="$(get_status || true)"
  [[ -n "$st" ]] || return 0
  echo "$st" | awk '{print $1}' | grep -Ei 'canary|server|otserv|game' || true
}

resolve_service() {
  local requested="$1"

  if service_exists "$requested"; then
    echo "$requested"
    return 0
  fi

  if [[ "$AUTO_DETECT_SERVICE" -eq 0 ]]; then
    return 1
  fi

  local candidates
  candidates="$(find_canary_candidates | sort -u || true)"

  if [[ -z "$candidates" ]]; then
    return 1
  fi

  local count
  count="$(echo "$candidates" | sed '/^$/d' | wc -l | tr -d ' ')"
  if [[ "$count" -eq 1 ]]; then
    echo "$candidates"
    return 0
  fi

  # Prefere match com 'canary' exatamente uma vez.
  local preferred
  preferred="$(echo "$candidates" | grep -Ei '^canary([:_-].*)?$' || true)"
  if [[ -n "$preferred" ]]; then
    local pcount
    pcount="$(echo "$preferred" | sed '/^$/d' | wc -l | tr -d ' ')"
    if [[ "$pcount" -eq 1 ]]; then
      echo "$preferred"
      return 0
    fi
  fi

  return 1
}

clear_logs() {
  mkdir -p "$(dirname "$OUT_LOG")" "$(dirname "$ERR_LOG")"
  : > "$OUT_LOG"
  : > "$ERR_LOG"
}

validate_number() {
  local value="$1"
  local label="$2"
  [[ "$value" =~ ^[0-9]+$ ]] || {
    echo "[erro] $label precisa ser numero inteiro >= 0" >&2
    exit 1
  }
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--service)
      SERVICE="${2:-}"
      shift 2
      ;;
    -o|--out-log)
      OUT_LOG="${2:-}"
      shift 2
      ;;
    -e|--err-log)
      ERR_LOG="${2:-}"
      shift 2
      ;;
    -n|--lines)
      TAIL_LINES="${2:-}"
      shift 2
      ;;
    -r|--retries)
      RETRIES="${2:-}"
      shift 2
      ;;
    -d|--delay)
      DELAY="${2:-}"
      shift 2
      ;;
    --no-follow)
      FOLLOW_TAIL=0
      shift
      ;;
    --no-clear)
      CLEAR_BEFORE=0
      shift
      ;;
    --errors)
      SHOW_ONLY_ERRORS=1
      shift
      ;;
    --no-auto-service)
      AUTO_DETECT_SERVICE=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[erro] opcao invalida: $1" >&2
      usage
      exit 1
      ;;
  esac
done

need_cmd awk
need_cmd tail
need_cmd supervisorctl
need_cmd sudo

validate_number "$TAIL_LINES" "--lines"
validate_number "$RETRIES" "--retries"
validate_number "$DELAY" "--delay"

if [[ "$SHOW_ONLY_ERRORS" -eq 1 ]]; then
  echo "[info] Servicos com possivel erro no Supervisor:"
  errors="$(print_error_services || true)"
  if [[ -z "$errors" ]]; then
    echo "[info] Nenhum servico em FATAL/BACKOFF/EXITED/STOPPED."
  else
    echo "$errors"
  fi
  exit 0
fi

RESOLVED_SERVICE="$(resolve_service "$SERVICE" || true)"
if [[ -z "$RESOLVED_SERVICE" ]]; then
  echo "[erro] Servico '$SERVICE' nao encontrado no Supervisor."
  echo "[info] Verifique os nomes disponiveis com:"
  echo "  sudo supervisorctl status"
  echo "[info] Candidatos detectados:"
  find_canary_candidates | sed 's/^/  - /' || true
  exit 1
fi
if [[ "$RESOLVED_SERVICE" != "$SERVICE" ]]; then
  echo "[info] Servico solicitado '$SERVICE' nao existe. Usando '$RESOLVED_SERVICE'."
  SERVICE="$RESOLVED_SERVICE"
fi

if [[ "$RETRIES" -eq 0 ]]; then
  echo "[info] --retries 0: nada para reiniciar."
else
  for ((i=1; i<=RETRIES; i++)); do
    echo "[info] Restart $i/$RETRIES -> $SERVICE"

    if [[ "$CLEAR_BEFORE" -eq 1 ]]; then
      echo "[info] Limpando logs: $OUT_LOG | $ERR_LOG"
      clear_logs
    fi

    run_supervisorctl restart "$SERVICE"

    if [[ "$i" -lt "$RETRIES" ]] && [[ "$DELAY" -gt 0 ]]; then
      sleep "$DELAY"
    fi
  done
fi

echo "[info] Status atual do Supervisor:"
get_status || true

echo "[info] Servicos com possivel erro:"
print_error_services || true

if [[ "$FOLLOW_TAIL" -eq 1 ]]; then
  echo "[info] tail -f ($TAIL_LINES linhas)"
  tail -n "$TAIL_LINES" -f "$OUT_LOG" "$ERR_LOG"
else
  echo "[info] tail ($TAIL_LINES linhas)"
  tail -n "$TAIL_LINES" "$OUT_LOG" "$ERR_LOG"
fi
