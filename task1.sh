#!/bin/bash

# Use bash {scriptname}.sh to run

# Get the directory where this script is currently located
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Change to that directory if needed
cd "$BASE_DIR" || {
    echo "Failed to change directory to $BASE_DIR"
    exit 1
}

# Output working directory 
echo "Now working in: $(pwd)"

# Initialisation

# Create a backup of the directory
BACKUP_DIR="$BASE_DIR/Backup"

# Create a log file in the base directory
LOG_FILE="$BASE_DIR/backup_log.txt"

# Constant that limits the backup_log.txt file to 50MB
WARNING_LIMIT_MB=50

# Function that generates a log of an event, stored in the variable LOG_FILE
log_event() {
    local msg="$1"
    # Stores the date and time, as well as log message
    printf "%s %s\n " "$(date '+%Y -%m -%d %H:%M:%S')" "$msg" >> "$LOG_FILE"
}

# Function that prints the menu screen
print_menu() {
    echo "University Data Centre Main Menu:"
    echo "1: Process Monitoring and Management"
    echo "2: Disk Inspection and Log Archiving"
    echo "3: Logging System"
    echo "4: Exit"
}

process_monitoring() {
    # Get the current usage of CPU and memory
    cpuUsage=$(top -bn1 | awk '/Cpu/ { print $2}')
    memUsage=$(free -m | awk '/Mem/{print $3}')
    
    # Print the usage
    echo "CPU Usage: $cpuUsage%"
    echo "Memory Usage: $memUsage MB"
}

disk_inspection() {
    echo "Not done yet"
}

logging_system() {
    echo "Not done yet"
}

exit() {
    echo "Not done yet"
}

# The main loop, which contains function calls
main() {
    # Creates the log file
    touch "$LOG_FILE"

while true; do
print_menu
# Reads in an input from the user
read -r -p "Please type in a valid number and hit Enter to select a choice: " choice
case "$choice" in 
1) process_monitoring;;
2) disk_inspection;;
3) logging_system;;
4) exit;;
# If none of the above numbers were inputted, output an error messafe
*) echo "Error: Invalid choice";;
esac
echo
done
}

main