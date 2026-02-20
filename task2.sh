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
    # %s means print a string value, %s\n means print on a new line"
    printf "%s %s\n " "$(date '+%Y -%m -%d %H:%M:%S')" "$msg" >> "$SCHEDULER_LOG"
}

print_menu() {
    echo "============================================================================================="
    echo "University High Performance Computing Laboratory Main Menu:"
    echo "1: View Pending Jobs"
    echo "2: Submit Job Request"
    echo "3: Process Job Queue Using Priority Scheduling"
    echo "4: View Completed Jobs"
    echo "============================================================================================="
    echo "5: View Scheduler Log"
    echo "6: Exit"
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
        # Output warning to the user
        echo "Warning: Job queue file not found. It will be created now."

        # Creates a new job queue file if the user deletes the previous one while the program is running 
        touch "$JOB_QUEUE"
        log_event "Job queue file made after attempt to check a non existing file"
    fi
}

submit_job_request() {
    # User inputs student ID, job name, execution time and priority
    read -rp "Enter your student ID, which is a number over 1000, then press Enter: " id
    read -rp "Enter your job name, then press Enter: " name
    read -rp "Enter the job's execution time, in seconds, then press Enter: " time
    read -rp "Enter the job's priority, from 1 (lowest) to 10 (highest), then press Enter: " priority

    # Input validation 1: Check for presence
    if [[ -z "$id" ]] || [[ -z "$name" ]] || [[ -z "$time" ]] || [[ -z "$priority" ]]; then
    echo "Error: One or more options are blank. Request denied!"
    log_event "Failed to submit job request: user submitted a blank option"

    # Input validation 2: Check for integers
    elif [[ -n ${time//[0-9]/} ]] || [[ -n ${priority//[0-9]/} ]] || [[ -n ${id//[0-9]/} ]]; then
    echo "Error: One or more options wanted an integer you didn't give. Request denied!"
    log_event "Failed to submit job request: user submitted letters instead of integers"

    # Input validation 3: Check priority range is between 1 to 10
    elif [ "$priority" -gt 10 ] || [ "$priority" -lt 1 ] ; then
    echo "Error: Priority must be between 1 to 10. Request denied!"
    log_event "Failed to submit job request: user submitted invalid priority"

    # Input validation 4: Check student ID is over 1000
    elif [ "$id" -lt 1001 ] ; then
    echo "Error: Student ID must be a number over 1000. Request denied!"
    log_event "Failed to submit job request: user submitted invalid student ID"

    else
    # Output a success message
    echo "Success! Student" "$id" "with job" "$name" ".Takes" "$time" "seconds. Priority of" "$priority"

    # Stores the student information in scheduler_log.txt and job_queue.txt
    msg="$id,$name,$time,$priority"
    printf "%s %s\n" "$(date '+%Y -%m -%d %H:%M:%S')" "$msg" "(Priority scheduling)" >> "$SCHEDULER_LOG"
    printf "%s %s\n" "$msg" >> "$JOB_QUEUE"
    fi
}

process_job_queue() {
    # Load the Job queue file
    FILE_NAME="$JOB_QUEUE"

    # User inputs their student ID
    read -rp "Enter your student ID, then press Enter: " id

    # Checks to see if their student ID has a job associated with it
    if grep -q "$id" job_queue.txt ; then
    echo "Student ID found on the job queue!"

    # Output messages to the user
    echo "The job process queue will begin now. You cannot stop once it starts."
    echo "Note: Priority Scheduling is used. Your job may not be done first!"
    log_event "Started to begin job queue"

    # Sorts the job queue based on priority. 10 has the highest priority.
    sort -t$',' -k4,4nr "$JOB_QUEUE"

    # For each student ID present in the job_queue.txt
    # Removes any whitespaces to process the data to be cut
    for line in $(sort -t',' -k4,4nr "$JOB_QUEUE" | tr -d '\r'); do

        # Gets the student ID from job_queue.txt 
        id=$(echo "$line" | cut -d',' -f1)

        # Gets the student name from job_queue.txt 
        name=$(echo "$line" | cut -d',' -f2)

        # Gets the job time from job_queue.txt 
        time=$(echo "$line" | cut -d',' -f3)

        # Gets the job priority from job_queue.txt 
        priority=$(echo "$line" | cut -d',' -f4)

        # Outputs a waiting message
        echo "Processing task..."

        # Simulates the system working on the task
        sleep "$time"

        # Outputs a confirmation message
        echo "Task "$name" for student "$id" done!"

    done
    # Output message when all jobs are completed
    echo "All tasks in the job queue are done!"

    # Transfer contents of job_queue.txt file to completed_jobs.txt
    cp "$JOB_QUEUE" "$COMPLETED_JOBS"
    echo "Moved the job queue into completed_jobs.txt."
    log_event "Moved contents of job_queue.txt to completed_job.txt"

    # Clears the job_queue.txt file
    > "$JOB_QUEUE"
    echo "Cleared the job queue file."
    log_event "Successfully cleared the job queue"

    else
    # Output error message if student ID is not present, or if the job queue is empty
    echo "Error: Your student ID is not found on the job queue"
    log_event "Failed to process jobs: student ID not found on job_queue.txt"

    fi

}

view_completed_jobs() {
    FILE_NAME="completed_jobs.txt"

    # If the completed jobs file exists, then output its contents
    if [ -e "$FILE_NAME" ]; then 
        content=$(cat "$FILE_NAME") 
        echo "$content"
        log_event "Read completed jobs file" 
    else 
        echo "Warning: Completed jobs file not found. It will be created now."

        # Creates a new completed jobs file if the user deletes the previous one
        touch "$COMPLETED_JOBS"
        log_event "Read completed jobs file made after attempt to check a non existing file"
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
    # While loop only breaks if the user inputs Y or N
    while true; do
        echo "You are about to exit the progam. Are you sure?"

        # Reads in user input
        read -r -p "Type Y and press Enter to confirm. Type N and press Enter to cancel. " ans

        # User input must match the valid inputs
        case "$ans" in
            Y|y)
                # Terminates the current process (the program) using a special Bash command to get PID
                kill $$ 
                ;;
            N|n)
                echo "Cancelled exit. You will be returned to the main menu."
                log_event "Cancelled exit of the program"
                ;;
            *)  
                echo "Error: neither Y or N was entered."
                log_event "Failed to exit the program"
                continue 
                ;;
        esac
        break
    done
}

main() {
    # Create the necessary log and job files when the program loads for the first time
    touch "$SCHEDULER_LOG"
    touch "$JOB_QUEUE"
    touch "$COMPLETED_JOBS"

while true; do
print_menu
# Reads in an input from the user
read -r -p "Please type in a valid number, and hit Enter to select a choice: " choice
case "$choice" in
1) view_pending_jobs;;
2) submit_job_request;;
3) process_job_queue;;
4) view_completed_jobs;; 
5) view_scheduler_log;;
6) exit;;
# If none of the above numbers were inputted, output an error message
*) echo "Error: Invalid choice!";;
esac
echo
done
}

main
