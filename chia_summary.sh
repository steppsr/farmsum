#!/bin/bash

# Define IP-to-name mapping
declare -A harvester_names=(
    ["127.0.0.1"]="JABBA"
    ["192.168.1.234"]="VADER"
    ["192.168.1.237"]="WEDGE"
    ["192.168.1.235"]="LANDO"
    ["192.168.1.145"]="KINNAKEET"
    ["192.168.1.137"]="TARKIN"
)

# ANSI color codes
BOLD="\033[1m"
RESET="\033[0m"
CYAN="\033[1;36m"
YELLOW="\033[0;33m"
GREEN="\033[0;32m"
MAGENTA="\033[0;35m"
WHITE="\033[1;37m"

chia farm summary | while IFS= read -r line; do
    # Match and colorize general farm info lines
    if [[ "$line" =~ ^(Farming|Total|User|Block|Last|Plot|Estimated|Expected|Note)[^:]*:[[:space:]]*(.*)$ ]]; then
        label="${line%%:*}:"
        value="${line#*: }"

        case "$label" in
            "Farming status:") color="${CYAN}" ;;
            "Total chia farmed:") color="${WHITE}" ;;
            "User transaction fees:") color="${WHITE}" ;;
            "Block rewards:") color="${WHITE}" ;;
            "Last height farmed:") color="${GREEN}" ;;
            "Plot count for all harvesters:") color="${GREEN}" ;;
            "Total size of plots:") color="${MAGENTA}" ;;
            "Estimated network space:") color="${MAGENTA}" ;;
            "Expected time to win:") color="${CYAN}" ;;
            "Note:") color="${CYAN}" ;;
            *) color="${RESET}" ;;
        esac

        printf "${WHITE}%-30s${RESET}\t${color}%s${RESET}\n" "$label" "$value"

    # Detect Local Harvester
    elif [[ "$line" =~ ^Local\ Harvester ]]; then
        current_ip="127.0.0.1"
        current_name="${harvester_names[$current_ip]}"

    # Detect Remote Harvester
    elif [[ "$line" =~ ^Remote\ Harvester\ for\ IP:\ ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+) ]]; then
        current_ip="${BASH_REMATCH[1]}"
        current_name="${harvester_names[$current_ip]}"

    # Match plot line
    elif [[ "$line" =~ ^[[:space:]]*([0-9]+)\ plots\ of\ size:\ ([0-9]+\.[0-9]+)\ TiB\ on-disk,\ ([-0-9]+\.[0-9]+)\ TiBe\ \(effective\) ]]; then
        plot_count="${BASH_REMATCH[1]}"
        size_disk="${BASH_REMATCH[2]}"
        size_effective="${BASH_REMATCH[3]}"
        printf "${CYAN}%-10s${RESET}\t\t\t${YELLOW}%-25s${RESET}\t${GREEN}%4s${RESET} ${CYAN}plots -${RESET} ${MAGENTA}%8s TiB${RESET} ${CYAN}on-disk,${RESET} ${MAGENTA}%8s TiBe${RESET} ${CYAN}(effective)${RESET}\n" "$current_name" "$current_ip" "$plot_count" "$size_disk" "$size_effective"

    fi
done
