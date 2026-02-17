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
LOG_FILE="$BASE_DIR/system_monitor_log.txt"

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
    echo "============================================================================================="
    echo "University Data Centre Main Menu:"
    echo "============================================================================================="
    echo "1: Show CPU and Memory Usage"
    echo "2: Show Top Ten Memory Consuming Processes"
    echo "3: Terminate A Selected Process"
    echo "============================================================================================="
    echo "4: Disk Inspection"
    echo "5: Create ArchiveLogs Directory"
    echo "6: Generate Text File"
    echo "7: Detect Log Files Over 50MB"
    echo "8: Compress Text File"
    echo "9: Check ArchiveLogs Directory"
    echo "============================================================================================="
    echo "30: Logging System"
    echo "40: Exit"
}

# Function that outputs the current CPU and memory usage
cpu_memory_usage() {

    # Gets the current usage of CPU and memory
    cpuUsage=$(top -bn1 | awk '/Cpu/ { print $2}')
    memUsage=$(free -m | awk '/Mem/{print $3}')
    
    echo "============================================================================================="
    # Outputs the usage to the user
    echo "CPU Usage: $cpuUsage%"
    echo "Memory Usage: $memUsage MB"
    echo "============================================================================================="

    log_event "Checked CPU and Memory usage"
}

top_ten_memory_processes() {
    # Generates a list of all active processes, then sorts them by the highest CPU usage first
    # Only the top 10 processes with the highest memory usage are outputted, along with the header
    echo "============================================================================================="
    ps aux --sort=-%cpu | head -n 11
    echo "============================================================================================="

    log_event "Checked top ten memory processes"
}

terminate_process() {
    echo "============================================================================================="
    echo "Currently Running Processes:"
    ps aux
    echo "============================================================================================="

    # Asks the user for PID
    read -rp "Enter the PID of the process you want to terminate: " pid

    # Checks the user of the process
    user=$(ps -p "$pid" -o user=)

    # If the user is systemd, then prevent terminating
    if [[ "$user" == systemd* ]]; then
        echo "Error: Cannot terminate a systemd process!"

    # If the user is root, then prevent terminating
    elif [[ "$user" == root ]]; then
        echo "Error: Cannot terminate a root process!"

    else
    echo "Are you sure you want to terminate this process?"

    # Requires the user to type Y or y to confirm termination
    read -r -p "Type Y and press Enter to confirm: " ans

    if [[ "$ans" != "Y" && "$ans" != "y" ]]; then
        echo "Cancelled termination of process "$pid" ."
        return
    fi

    # Terminates the process using the default kill signal SIGTERM (15)
    kill "$pid"
    echo "Process "$pid" terminated successfully!"
    fi 
}

disk_inspection() {
    echo "============================================================================================="
    echo "Disk usage for this directory:"

    # Outputs disk usage based on files in the base directory only
    du -sh "$BASE_DIR"
    echo "============================================================================================="
    echo "Disk usage for the entire system:"

    # Outputs disk usage based on files on the system
    df -h
    echo "============================================================================================="

    # Tutorial on how to read the output
    echo "K means kilobytes. For example, 50K means 50KB of storage used."
    echo "K means megabytes. For example, 50M means 50MB of storage used."
    echo "G means gigabytes. For example, 50G means 50GB of storage used."
    echo "============================================================================================="
}

create_archive_logs_directory() {
    echo "============================================================================================="
    echo "This will make an ArchiveLogs directory in your current location."

    # Requires the user to type Y or y to confirm termination
    read -r -p "Type Y and press Enter to confirm: " ans

    if [[ "$ans" != "Y" && "$ans" != "y" ]]; then
        echo "Cancelled ArchiveLogs directory creation."
        log_event "Cancelled ArchiveLogs directory creation"
        return
    fi

    # Creates a variable that has the relative path to ArchiveLogs
    CHECK_DIRECTORY="$BASE_DIR/ArchiveLogs" 

    # If it matches, then the directory already exists and an error message will be outputted
    if [ -d "$CHECK_DIRECTORY" ]; then
        echo "Error: $CHECK_DIRECTORY already exists!"
        log_event "Failed to make ArchiveLogs directory: already exists"

    else
    mkdir -v ArchiveLogs
    log_event "Successfully created ArchiveLogs directory"
    fi
}

generate_text_file() {
    # Generates a large text file that can be used for testing (codemonkey, 2020)
    tr -dc "A-Za-z 0-9" < /dev/urandom | fold -w100|head -n 600000 > biglogfile.txt
    echo "All done!"
}

detect_large_log_file() {
    # Gets the size of any files with log in their name, cuts everything else so it can be compared
    # grep is used to filter the command to just store the total 
    size=$(du -cm *log* | grep total | cut -f1)

    # Outputs the size of file logs to the user
    echo "File size of logs: " $size "MB"

    if [ "$size" -gt 50 ] ; then
        echo "Warning: Log files over 50MB detected in main directory!"
        log_event "Ran large log file check: Log files over 50MB detected"

    else
        echo "No log files over 50MB detected in main directory"
        log_event "Ran large log file check: No log files over 50MB detected"

    fi
}

compress_text_file() {

    # Requires the user to input the file name they want to compress
    echo "============================================================================================="
    read -r -p "Type the file name, including the .txt part, and press Enter: " file

    # Checks to see whether the file exists in the directory
    CHECK_FILE="$BASE_DIR/$file"
    if [ -f "$CHECK_FILE" ]; then
        echo "Success: File exists."

        # Compress the file to a .zip, making it compatible with Windows and macOS
        zip -v "$(date '+%Y -%m -%d %H %M')".zip "$CHECK_FILE"
        ZIP_FILE="$(date '+%Y -%m -%d %H %M')".zip
        echo "File successfully compressed into a .zip file."

        log_event "Compressed $CHECK_FILE to a .zip file."

        # Creates a variable that has the relative path to ArchiveLogs
        CHECK_DIRECTORY="$BASE_DIR/ArchiveLogs" 

        # If it does not exist, then an error message will be outputted
        if [ ! -d "$CHECK_DIRECTORY" ]; then
            echo "Error: ArchiveLogs directory does not exist!"
            echo "Unable to move the .zip file. It will be stored in the base directory instead."
            log_event "Failed to move .zip file: could not find ArchiveLogs directory"

        else
        mv "$ZIP_FILE" "$BASE_DIR/ArchiveLogs"

        echo "File successfuly moved to the ArchiveLogs directory"
        echo "==========================================================================================="
        log_event "Moved .zip file to ArchiveLogs directory"
        fi

    else
        echo "Error: File does not exist!"
        log_event "Failed to compress a .txt file: could not find in directory"
    fi
}

check_archive_logs_directory() {
    # Creates a variable that has the relative path to ArchiveLogs
    CHECK_DIRECTORY="$BASE_DIR/ArchiveLogs" 

    # If it does not exist, then an error message will be outputted
    if [ ! -d "$CHECK_DIRECTORY" ]; then
        echo "Error: ArchiveLogs directory does not exist!"
        log_event "Failed to check directory: could not find ArchiveLogs directory"

    else
    # Get the size of the ArchiveLogs directory in MB
    size=$(du -sm "$CHECK_DIRECTORY" | cut -f 1)

    # Output the size to the user
    echo "ArchiveLogs directory is" $size "MB"

    # Prints a warning message if the directory is over 1GB
    if [ "$size" -gt 1000 ] ; then
        echo "Warning: ArchiveLogs directory is over 1GB in size!"
        log_event "ArchiveLogs directory was checked: over 1GB in size"
    
    else
        echo "ArchiveLogs is under 1GB in size"
        log_event "ArchiveLogs directory was checked: under 1GB in size"
    fi

    fi
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
1) cpu_memory_usage;;
2) top_ten_memory_processes;;
3) terminate_process;;
4) disk_inspection;;
5) create_archive_logs_directory;;
6) generate_text_file;;
7) detect_large_log_file;;
8) compress_text_file;;
9) check_archive_logs_directory;;
30) logging_system;;
40) exit;;
# If none of the above numbers were inputted, output an error message
*) echo "Error: Invalid choice";;
esac
echo
done
}

main