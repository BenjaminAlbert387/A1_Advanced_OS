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

# Creates a variable for the log file in the base directory
SUBMISSION_LOG="$BASE_DIR/submission_log.txt"

# Creates a variable for the submitted assigments directory
SUBMITTED_ASSIGNMENTS="$BASE_DIR/Submitted_Assignments"

# Function that generates a log of an event, stored in the variable SCHEDULER_LOG
log_event() {
    local msg="$1"
    # Stores the date and time, as well as log message
    # %s means print a string value, %s\n means print on a new line"
    printf "%s %s\n " "$(date '+%Y -%m -%d %H:%M:%S')" "$msg" >> "$SUBMISSION_LOG"
}

print_menu() {
    echo "============================================================================================="
    echo "University Examination Board Main Menu:"
    echo "1: Submit Assignment"
    echo "5: Exit"
    echo "============================================================================================="
}

submit_assignment() {
    echo "============================================================================================="
    read -r -p "Type the file name, including the .pdf part, and press Enter: " file

    # Checks to see whether the file exists in the directory
    CHECK_FILE="$BASE_DIR/$file"
    if [ -f "$CHECK_FILE" ]; then
        echo "Success: File exists."

    else
        echo "Error: File does not exist!"
        log_event "Failed to submit assignment: could not find in directory"
    fi

    DUPLICATE_FILE=""
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

main () {
    # Create the necessary log and directory when the program loads for the first time
    touch "$SUBMISSION_LOG"
    mkdir Submitted_Assignments

while true; do
print_menu
# Reads in an input from the user
read -r -p "Please type in a valid number, and hit Enter to select a choice: " choice
case "$choice" in
5) exit;;
# If none of the above numbers were inputted, output an error message
*) echo "Error: Invalid choice!";;
esac
echo
done
}

main