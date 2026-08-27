#!/usr/bin/env bash

clear; bash banner.sh

# Require sudo
SUDO_JOKES=(
    "Come on man, even the roulette needs sudo."
    "No sudo, no roulette. That's the deal."
    "Bro, where is your sudo?"
    "You forgot the magic word: sudo."
    "Root privileges, man. We need to talk."
    "Nice try. Now run it with sudo."
    "The wheel refuses to spin without sudo."
)

if [ "$EUID" -ne 0 ]; then

    joke=$((RANDOM % ${#SUDO_JOKES[@]}))

    printf "[!] %s\n" "${SUDO_JOKES[$joke]}"
    exit 1
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

cleanup()
{
    printf "\n\n${RED}[!] PID Roulette stopped.${RESET}\n"
    exit 0
}

trap cleanup INT TERM

BOLD='\033[1m'

printf "[+] Everything is ready. Let's see who's unlucky.\n"

while true; do

    mapfile -t PIDS < <(ps -e -o pid= | awk '{print $1}')
    total=${#PIDS[@]}

    if [ "$total" -eq 0 ]; then
        printf "${RED}[!] No processes found.${RESET}\n"
        sleep 1
        continue
    fi

    printf "[${YELLOW}?${RESET}] CONTINUE"

    if [ "$1" != "--auto" ]; then
        read -r
    fi

    # Overwrite CONTINUE
    printf "\033[1A\033[2K"

    delay=0.02

    for ((i = 0; i < 30; i++)); do

        index=$(( (RANDOM * RANDOM * RANDOM) % total ))

        pid="${PIDS[$index]}"
        name=$(ps -p "$pid" -o args= 2>/dev/null)

        if [ "${#name}" -gt 85 ]; then
            name="${name:0:82}..."
        fi

        printf "\r\033[2K[${CYAN}-${RESET}] %-7s %-85s [${YELLOW}-SPIN-${RESET}]" "$pid" "$name"

        sleep "$delay"

        delay=$(awk -v d="$delay" 'BEGIN {
            d += 0.006

            if (0.15 < d)
                d = 0.15

            printf "%.3f", d
        }')
    done
    selected_pid="${PIDS[$index]}"
    selected_name=$(ps -p "$selected_pid" -o args= 2>/dev/null)

    if [ "${#selected_name}" -gt 64 ]; then
        selected_name="${selected_name:0:82}..."
    fi

    printf "\r\033[2K[${GREEN}-${RESET}] %-7s %-85s [${GREEN}SELECT${RESET}]" "$selected_pid" "$selected_name"

    sleep 1

    printf "\r\033[2K[${RED}-${RESET}] %-7s %-85s [${RED}${BOLD}KILLED${RESET}]\n" "$selected_pid" "$selected_name"

    kill -1 "$selected_pid"
    sleep 1
done
