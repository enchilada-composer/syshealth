#!/bin/bash

# Color codes
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

# Default settings
LOGGING=false
COLOR=true
LIVE_OUTPUT=false
INTERVAL=5 # seconds

# Function to print usage
usage() {
    echo "Usage: $0 [-l|--log] [-c|--color] [-t|--tail] [-h|--help]"
    echo ""
    echo "Options:"
    echo "  -l, --log      Enable logging to file"
    echo "  -c, --color    Enable color output"
    echo "  -t, --tail     Show live log output"
    echo "  -h, --help     Show this help message"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -l|--log)
            LOGGING=true
            shift
            ;;
        -c|--color)
            COLOR=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -t|--tail)
            LIVE_OUTPUT=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Function to get CPU usage
get_cpu_usage() {
    local cpu=$(top -bn2 | grep "Cpu(s)" | tail -1 | awk '{print $2 + $4}')
    echo "$cpu"
}

# Function to get memory usage
get_memory_usage() {
    local mem=$(free | grep Mem | awk '{print ($3/$2) * 100}')
    echo "$mem"
}

# Function to get disk usage
get_disk_usage() {
    local root=$(df / | grep / | awk '{print ($3/$2)*100}')
    echo "$root"
}

# Function to get network stats
get_network_stats() {
    local rx=$(cat /sys/class/net/$(ip route get 8.8.8.8 | awk '{print $5}')/statistics/rx_bytes)
    local tx=$(cat /sys/class/net/$(ip route get 8.8.8.8 | awk '{print $5}')/statistics/tx_bytes)
    echo "$rx $tx"
}

# Function to get temperature
get_temperature() {
    if command -v sensors &> /dev/null; then
        local temp=$(sensors | grep "Package id 0:" | awk '{print $4}' | sed 's/+//')
        echo "$temp"
    else
        echo "N/A"
    fi
}

# Function to format percentage with color
format_percentage() {
    local value=$1
    local color=$NC
    
    if (( $(echo "$value > 75" | bc -l) )); then
        color=$RED
    elif (( $(echo "$value > 50" | bc -l) )); then
        color=$YELLOW
    else
        color=$GREEN
    fi
    
    echo -e "${color}${value}%${NC}"
}

# Main monitoring loop
while true; do
    # If live output is enabled, show the log file
    if [ "$LIVE_OUTPUT" = true ]; then
        clear
        echo -e "${BLUE}System Health Monitor - Live Log${NC}"
        echo "============================="
        echo ""
        tail -n 20 syshealth.log
        echo ""
        echo -e "${YELLOW}Press Ctrl+C to exit${NC}"
        sleep 1
        continue
    fi
    
    clear
    
    echo -e "${BLUE}System Health Monitor${NC}"
    echo "====================="
    echo ""
    
    # CPU Usage
    cpu=$(get_cpu_usage)
    echo -e "CPU Usage: $(format_percentage $cpu)"
    
    # Memory Usage
    mem=$(get_memory_usage)
    echo -e "Memory Usage: $(format_percentage $mem)"
    
    # Disk Usage
    disk=$(get_disk_usage)
    echo -e "Disk Usage: $(format_percentage $disk)"
    
    # Network Stats
    read rx tx < <(get_network_stats)
    echo -e "Network: RX: ${YELLOW}$(echo "scale=2; $rx/1024/1024" | bc) MB${NC} TX: ${YELLOW}$(echo "scale=2; $tx/1024/1024" | bc) MB${NC}"
    
    # Temperature
    temp=$(get_temperature)
    echo -e "Temperature: ${temp}°C"
    
    # Log to file if enabled
    if [ "$LOGGING" = true ]; then
        echo "$(date) - CPU: $cpu%, MEM: $mem%, DISK: $disk%, RX: $rx, TX: $tx, TEMP: $temp" >> syshealth.log
    fi
    
    # Wait for next iteration
    sleep $INTERVAL
done
