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

    # Gets the size of the file in MB
    size=$(du -sm "$CHECK_FILE" | cut -f 1)

    if [ -f "$CHECK_FILE" ]; then
        echo "Success: File exists in the base directory."

        # Input validation 1: Check for matching file names
        DUPLICATE_FILE="$BASE_DIR/Submitted_Assignments/$file"
        if [ -f "$DUPLICATE_FILE" ]; then
            echo "Error: File with the same name has already been submitted"
            log_event "Failed to submit assignment: file name already used"

        # Input validation 2: Check for supported file types
        elif [[ $CHECK_FILE != *".pdf"* && $CHECK_FILE != *".docx"* ]]; then
            echo "Error: File type not supported"
            log_event "Failed to submit assignment: file type not supported"

        # Input validation 3: Check if the file is over 5MB
        elif [ "$size" -gt 5 ] ; then
            echo "Warning: File is over 5MB in size!"
            log_event "Failed to submit assignment: file is over 5MB"

        else
            echo "No file name issues"
        fi

        for all_files in "$SUBMITTED_ASSIGNMENTS"/*; do
            # Prevents the file checking itself
            [[ "$all_files" == "$CHECK_FILE" ]] && continue

            # Removes all whitespace in both files
            # tr -d deletes any spaces, tabs and line breaks in each file
            remove_whitespace_check=$(tr -d '[:space:]' < "$CHECK_FILE")
            remove_whitespace_all=$(tr -d '[:space:]' < "$all_files")

            # Input validation 4: Check for matching file contents
            if [[ "$remove_whitespace_check" == "$remove_whitespace_all" ]]; then
                echo "Error: File has exact matching content found!"
                log_event "Failed to submit assignment: exact matching content found"
                break
            fi
        done

        
    else
        echo "Error: File does not exist in the base directory!"
        log_event "Failed to submit assignment: could not find in directory"
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

main () {
    # Create the necessary log and directory when the program loads for the first time
    touch "$SUBMISSION_LOG"
    mkdir Submitted_Assignments

while true; do
print_menu
# Reads in an input from the user
read -r -p "Please type in a valid number, and hit Enter to select a choice: " choice
case "$choice" in
1) submit_assignment;;
5) exit;;
# If none of the above numbers were inputted, output an error message
*) echo "Error: Invalid choice!";;
esac
echo
done
}

main