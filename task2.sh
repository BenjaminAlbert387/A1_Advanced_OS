#!/bin/bash

# Use bash {scriptname}.sh to run

# Get the directory where this script is currently located
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Change to that directory if needed
cd "$BASE_DIR" || {
    echo "Failed to change directory to $BASE_DIR"
    kill $$
}

# Output working directory 
echo "Now working in: $(pwd)"

# Initialisation

# Create log files in the base directory
SCHEDULER_LOG="$BASE_DIR/scheduler_log.txt"
JOB_QUEUE="$BASE_DIR/job_queue.txt"
COMPLETED_JOBS="$BASE_DIR/completed_jobs.txt"

# Function that generates a log of an event, stored in the variable SCHEDULER_LOG
log_event() {
    local msg="$1"
    # Stores the date and time, as well as log message
    printf "%s %s\n " "$(date '+%Y -%m -%d %H:%M:%S')" "$msg" >> "$SCHEDULER_LOG"
}

print_menu() {
    echo "============================================================================================="
    echo "University High Performance Computing Laboratory Main Menu:"
    echo "1: View Pending Jobs"
    echo "19: View Scheduler Log"
    echo "20: Exit"
    echo "============================================================================================="
}

view_pending_jobs() {
    FILE_NAME="job_queue.txt"

    # If the job queue file exists, then output its contents
    if [ -e "$FILE_NAME" ]; then 
        content=$(cat "$FILE_NAME") 
        echo "$content"
        log_event "Viewed pending jobs list" 

    else 
        echo "Warning: Job queue file not found. It will be created now."

        # Creates a new job queue file if the user deletes the previous one while the program is running 
        touch "$JOB_QUEUE"
        log_event "Job queue file made after attempt to check a non existing file"
    fi
}

view_scheduler_log() {
    FILE_NAME="scheduler_log.txt"

    # If the log file exists, then output its contents
    if [ -e "$FILE_NAME" ]; then 
        content=$(cat "$FILE_NAME") 
        echo "$content"
        log_event "Read scheduler log file" 
    else 
        echo "Warning: Scheduler log file not found. It will be created now."

        # Creates a new log file if the user deletes the previous one while the program is running 
        touch "$LOG_FILE"
        log_event "Scheduler log file made after attempt to check a non existing file"
    fi
}

exit() {
    echo "This will close the program. Are you sure?"

    # Requires the user to type Y or y to confirm exit
    read -r -p "Type Y and press Enter to confirm. Type anything else to cancel. " ans

    if [[ "$ans" != "Y" && "$ans" != "y" ]]; then
        echo "Cancelled exit."

    else
        # Terminates the current process (the program) using a special Bash command to get PID
        kill $$    
    fi
}

main() {
    # Create the necessary log and job files
    #touch "$SCHEDULER_LOG"
    #touch "$JOB_QUEUE"
    #touch "$COMPLETED_JOBS"

while true; do
print_menu
# Reads in an input from the user
read -r -p "Please type in a valid number and hit Enter to select a choice: " choice
case "$choice" in
1) view_pending_jobs;;
19) 
20) exit;;
# If none of the above numbers were inputted, output an error message
*) echo "Error: Invalid choice";;
esac
echo
done
}

main
