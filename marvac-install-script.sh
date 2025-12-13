#!/bin/bash
set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_NAME="MarVac postinstall OS script"
SCRIPT_VERSION="1.0"
SCRIPT_DATE="2025-01-13"
SCRIPT_AUTHOR="marek@vach.cz"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TASKS_DIR="$SCRIPT_DIR/tasks"
TMP_DIR="$SCRIPT_DIR/tmp"
LOGFILE="$SCRIPT_DIR/install-script.log"

DRY_RUN=false
for arg in "$@"; do
	case "$arg" in
        --dry-run)
            DRY_RUN=true
            ;;
        *)
            echo "Undefined parameter: $arg. End of script."
            exit 1
            ;;
    esac
done

#######################################
# Functions
#######################################
require_root() {
	if [[ $EUID -ne 0 ]]; then
		echo "Script must be run with sudo. Reloading script with sudo command..."
		exec sudo bash "$0" "$@"
	fi
}

log() {
	echo
	echo "[$(date '+%F %T')] $*" | tee -a "$LOGFILE"
	sleep 2
}

run() {
	if $DRY_RUN; then
		log "[DRY-RUN] $*"
	else
		"$@"
	fi
}

APT_DONE=0
apt_once() {
	if [[ $APT_DONE -eq 0 ]]; then
		local skip_update=false

		if [[ -f /var/lib/apt/periodic/update-success-stamp ]]; then
			local last_update=$(stat -c %Y /var/lib/apt/periodic/update-success-stamp)
			local now=$(date +%s)
			local diff=$((now - last_update))

			if (( diff < 3600 )); then  # 3600 sekund = 1 hodina
				log "Poslední update byl před méně než hodinou. Přeskakuji apt-get update/upgrade."
				skip_update=true
			fi
		fi

		if ! $skip_update; then
			log "Provádím systémový update a upgrade (pouze jednou)..."
			set +e   # dočasně ignorujeme chyby
			run apt-get update -y
			run apt-get upgrade -y || true
			set -e
		fi

		APT_DONE=1
	fi
}

apt_install() {
	apt_once
	run apt-get install -y --no-install-recommends "$@"
}

install_dependencies() {
	apt_once
	log "Installing utilities used by the script..."
	local deps=(wget curl ca-certificates gnupg yes expect unzip)
	for pkg in "${deps[@]}"; do
		if ! dpkg -s "$pkg" &>/dev/null; then
			apt_install "$pkg"
		fi
	done
}

declare -A TASK_DESC
declare -A TASK_FUNC

load_tasks() {
	if [[ -d "$TASKS_DIR" ]]; then
		chmod +x "$TASKS_DIR"/*.sh
		log "Všechny subskripty ve složce tasks jsou nyní nastavené jako spustitelné."
	else
		log "Chyba: složka tasks neexistuje. Skript končí."
		exit 1
	fi

	log "Načítám subskripty z $TASKS_DIR..."
	for file in "$TASKS_DIR"/*.sh; do
		local base=$(basename "$file")
		local task_id="${base%%-*}"    # část před prvním "-"
		task_id=$((10#$task_id))       # odstraní přední nuly

		local desc=$(sed -n '2s/^# *//p' "$file")
		[[ -n "$desc" ]] || desc="Bez popisu"

		TASK_DESC[$task_id]="$desc"
		TASK_FILE[$task_id]="$file"
	done
}

run_task() {
	local id="$1"
	local desc="${TASK_DESC[$id]}"
	local file="${TASK_FILE[$id]}"

	log "Spouštím úlohu: [$id] $desc"

	# spustíme subskript přes source, aby měl přístup k funkcím a proměnným hlavního skriptu
	if source "$file"; then
		log "Dokončeno: [$id] $desc"
	else
		log "Chyba při vykonávání úlohy [$id] $desc. Skript končí."
		exit 1
	fi
}

#######################################
# GUI Menu
#######################################
show_menu() {
	echo
	echo "$SCRIPT_NAME v$SCRIPT_VERSION ($SCRIPT_DATE)"
	echo
	echo "0) Přeji si udělat všechny následující kroky."
	for id in $(printf "%s\n" "${!TASK_DESC[@]}" | sort -n); do
		echo "$id) ${TASK_DESC[$id]}"
	done
	echo "100) Ukončit skript."
	echo
}

main() {
	read -rp "Napiš čísla úloh oddělené čárkou, které se mají automaticky vykonat: " INPUT
	IFS=',' read -ra CHOICES <<< "$INPUT"

	for choice in "${CHOICES[@]}"; do
		choice="$(xargs <<<"$choice")"
		# normalizujeme vstup na číslo
		choice=$((10#$choice))

		[[ "$choice" == 100 ]] && exit 0

		if [[ "$choice" == 0 ]]; then
			for id in $(printf "%s\n" "${!TASK_FILE[@]}" | sort -n); do
				run_task "$id"
			done
      		break
    	fi

    	if [[ -z "${TASK_FILE[$choice]:-}" ]]; then
      		log "Neexistující položka v menu, přeskakuji: $choice"
      		continue
    	fi

    	run_task "$choice"
	done
	log "Skript doběhl do konce. Ukončuji..."
}

#######################################
# START
#######################################
require_root
install_dependencies
load_tasks
show_menu
main

