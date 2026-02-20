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

login_menu() {
    echo "============================================================================================="
    # Inital attempts and max attempts
    MAX_ATTEMPTS=3
    INITIAL_ATTEMPT=1

    # While attempts is under 3
    while [ $INITIAL_ATTEMPT -lt $MAX_ATTEMPTS ] do
        read -p "Enter your username, then press Enter: " username
        # Password input is hidden
        read -sp "Enter your password, then press Enter: " password

        # Checks if the login details are correct
        if [[ "$username" == "cccu" && "$password" == "education1!" ]]; then
            echo "Login successful"
            main

}

print_menu() {
    echo "============================================================================================="
    echo "University Examination Board Main Menu:"
    echo "1: Create Submitted_Assignments Directory"
    echo "2: Submit Assignment"
    echo "3: Check Submitted Files"
    echo "4: Check Submitted_Assignments Directory"
    echo "9: Exit"
    echo "============================================================================================="
}

create_submitted_assignments_directory() {
    echo "============================================================================================="
    echo "This will make an Submitted_Assignments directory in your current location."

    # Requires the user to type Y or y to confirm termination
    read -r -p "Type Y and press Enter to confirm: " ans

    if [[ "$ans" != "Y" && "$ans" != "y" ]]; then
        echo "Cancelled Submitted_Assignments directory creation."
        log_event "Cancelled Submitted_Assignments directory creation"
        return
    fi

    # Creates a variable that has the relative path to Submitted_Assignments
    CHECK_DIRECTORY="$BASE_DIR/Submitted_Assignments" 

    # If it matches, then the directory already exists and an error message will be outputted
    if [ -d "$CHECK_DIRECTORY" ]; then
        echo "Error: $CHECK_DIRECTORY already exists!"
        log_event "Failed to make Submitted_Assignments directory: already exists"

    else
    mkdir -v Submitted_Assignments
    log_event "Successfully created Submitted_Assignments directory"
    fi
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
            log_event "Failed to submit assignment "$file": file name already used"

        # Input validation 2: Check for supported file types
        elif [[ $CHECK_FILE != *".pdf"* && $CHECK_FILE != *".docx"* ]]; then
            echo "Error: File type not supported"
            log_event "Failed to submit assignment "$file": file type not supported"

        # Input validation 3: Check if the file is over 5MB
        elif [ "$size" -gt 5 ] ; then
            echo "Warning: File is over 5MB in size!"
            log_event "Failed to submit assignment "$file": file is over 5MB"

        else
            echo ""
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
                log_event "Failed to submit assignment "$file": exact matching content found"
                break
            fi
        done

        echo "Uploading "$file" now..."
        sleep 2

        # Transfer file to Submitted_Assignments directory
        cp "$CHECK_FILE" Submitted_Assignments

        # Output success message to the user and logs event
        echo "Successfully uploaded "$file"!"
        log_event "Submission "$file" uploaded successfully."        

        
    else
        echo "Error: File does not exist in the base directory!"
        log_event "Failed to submit assignment: could not find in directory"
    fi
}

check_submitted_files() {
    # Requires the user to input the file name they want to check
    echo "============================================================================================="
    read -r -p "Type the file name, including the .pdf part, and press Enter: " file

    # Checks to see whether the file exists in the directory
    CHECK_FILE="$BASE_DIR/$file"
    if [ -f "$CHECK_FILE" ]; then
        echo "Success: File exists in the base directory."

        # Check for matching file names in Submitted_Assignments
        DUPLICATE_FILE="$BASE_DIR/Submitted_Assignments/$file"
        if [ -f "$DUPLICATE_FILE" ]; then
            echo "File with the same name has already been submitted. Rename it."
            log_event "Checked submitted files: one or more files matched names"
        else
            echo "No files submitted had a matching name."
            log_event "Checked submitted files: no files matched names"
        fi

    else
        echo "Error: File does not exist!"
        log_event "Failed to check file: could not find in directory"
    fi
    }

check_submitted_assignments_directory() {
    echo "============================================================================================="
    # Creates a variable that has the relative path to Submitted_Assignments
    CHECK_DIRECTORY="$BASE_DIR/Submitted_Assignments" 

    # If it does not exist, then an error message will be outputted
    if [ ! -d "$CHECK_DIRECTORY" ]; then
        echo "Error: Submitted_Assignments directory does not exist!"
        log_event "Failed to check directory: could not find Submitted_Assignments directory"

    else
        echo "All currently submitted files:"
        ls $CHECK_DIRECTORY
        log_event "Successfully checked Submitted_Assignments directory"
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
    # Create the necessary log file when the program loads for the first time
    touch "$SUBMISSION_LOG"

while true; do
print_menu
# Reads in an input from the user
read -r -p "Please type in a valid number, and hit Enter to select a choice: " choice
case "$choice" in
1) create_submitted_assignments_directory;;
2) submit_assignment;;
3) check_submitted_files;;
4) check_submitted_assignments_directory;;
9) exit;;
# If none of the above numbers were inputted, output an error message
*) echo "Error: Invalid choice!";;
esac
echo
done
}

login_menu