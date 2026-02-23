# Use python {path to the file}/task.py in powershell terminal, then press Enter to run
# For example: python C:\Users\benja\Documents\GitHub\A1_Advanced_OS\task3.py

# Initialisation: import modules when the program is run
import os
import sys
from datetime import datetime
import fnmatch
import filecmp
import time
import shutil
import getpass

# Get the directory where this script is located
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Change to that directory
try:
    os.chdir(BASE_DIR)
except Exception as e:
    print(f"Failed to change directory to {BASE_DIR}: {e}")
    sys.exit(1)

# Output working directory
print("Now working in:", os.getcwd())

def log_event(msg):
    # Creates submission_log.txt if it does not exist, else open and prepare to append it
    open("submission_log.txt", "a")

    # Variable that stores the date and time in a readable format
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S") 

    # Append submission_log.txt with timestamp and msg variables in a formatted string
    with open("submission_log.txt", "a", encoding="utf-8") as f: 
        f.write(f"{timestamp} {msg}\n")

def login_menu_function():
    max_attempts = 4
    inital_attempt = 1
    attempt_time = []

    while inital_attempt < max_attempts:
        username = input("Enter your username, then press Enter: ")

        # Hides the password from being shown while entered
        password = getpass.getpass("Enter your password, then press Enter: ")

        if username == "cccu" and password == "cccu1!":
            print("Login successful!")
            log_event("User successfully logged in to the program")
            menu_function()

        else:
            print("Unsuccessful login attempt")
            log_event(f"Attempt {inital_attempt}: failed to login to program")
            print(f"Attempt {inital_attempt} of 3 used!")

            # Converts the current date and time into epoch seconds
            epoch = int(time.time())

            # Stored in the log file
            log_event(epoch)

            attempt_time.append(epoch)

            # If there are three times in the attempt_time array (length is 3)
            if len(attempt_time) == 3:

                # Get the first attempt time in the array 
                first_attempt_time = attempt_time[0]

                # Get the third attempt time in the array
                third_attempt_time = attempt_time[2]

                # If the difference is 60 seconds or less
                if third_attempt_time - first_attempt_time <= 60:

                    # Print additional messages and log events
                    print("Suspicious activity detected!")
                    log_event("User attempted to login three times within 60 seconds")

                # Clears the array
                attempt_time = []

        # Increment attempt by 1
        inital_attempt += 1
    
    # Ends the program if the user reaches the maximum password attempts
    print("You have reached the maximum attempts! The system has been locked.")
    log_event("User failed to login within three attempts")

def create_submitted_assignments_py_directory_function():
        # Specifies the directory name
        directory_name = "Submitted_Assignments_Py"

        # Creates the directory
        try:
            os.mkdir(directory_name)

            # Ouptut success message to the user
            print(f"Directory '{directory_name}' created successfully.")
            log_event("Submitted_Assignments_Py created successfully")
        
        # Python class that is true if the directory already exists
        except FileExistsError:
            print(f"Error: Directory '{directory_name}' already exists.")
            log_event("Failed to create Submitted_Assignments_Py: already exists")

        # Python class that is true if the user does not have permissions
        except PermissionError:
            print(f"Error: Permission denied, unable to create '{directory_name}'.")
            log_event("Failed to create Submitted_Assignments_Py: permission denied")

        # Python class that is true for any other error
        except Exception as e:
            print(f"Error: Other error occurred: {e}")
            log_event("Failed to create Submitted_Assignments_Py: exception error")

        menu_function()

def submit_assignment_function():
    # If the Submitted_Assignments_Py directory does not exist
    if os.path.isdir("Submitted_Assignments_Py") == False:
        print("Error: Please create Submitted_Assignments_Py first!")
        log_event("Failed to submit assignment: missing Submitted_Assignments_Py directory")
        menu_function()

    # User inputs their student ID
    while True:
        try:
            student_id = int(input("Type your student ID, a number over 1000, then press Enter: "))
            if student_id > 1000:
                print("Valid student ID")
                break

            else:
                print("Error: student ID not found")
                log_event("Failed to submit assignment: user submitted invalid student ID")
                menu_function()

        except ValueError:
            print("Error: invalid input")
            menu_function()

    # User inputs the file name
    file = input("Type the file name you want to upload, including the .pdf part, and press Enter: ")

    # Variable that stores the path of the base directory and file name inputted
    check_file = os.path.join(BASE_DIR, file)

    # Variable that stores the extension of the file name inputted
    ext_file = os.path.splitext(file)[-1].lower()

    # Variable that stores the size of the file in bytes
    # To convert bytes to MB, times by 1,000,000
    size_file = os.path.getsize(file)

    # Checks to see whether the file exists in the base directory 
    if os.path.exists(check_file) == True:
        print("File exists in the base directory")

        # Input validation 1: Check for matching file names
        for files in os.listdir("Submitted_Assignments_Py"):
            if fnmatch.fnmatch(file, files):
                print("Error: File with the same name has already been submitted")
                log_event(f"Assignment {file} for {student_id}: Status: fail (file name matches)")
                menu_function()

        # Input validation 2: Check for supported file types
        if ext_file != ".docx" and ext_file != ".pdf":
            print("Error: File type not supported")
            log_event(f"Assignment {file} for {student_id}: Status: fail (file type unsupported)")
            menu_function()

        # Input validation 3: Check if the file is over 5MB
        if size_file > 5 * 1000000:
            print("Error: File is over 5MB in size!")
            log_event(f"Assignment {file} for {student_id}: Status: fail (file size over 5MB)")
            menu_function()

        # Input validation 4: Check for matching file contents
        # For each file in Submitted_Assignments_Py directory
        for files in os.listdir("Submitted_Assignments_Py"):

            # Variable that stores the full path of files in Submitted_Assignments_Py
            full_path = os.path.join("Submitted_Assignments_Py", files)

            if os.path.isfile(full_path):
                # If the file contents match any file in Submitted_Assignments_Py
                if filecmp.cmp(check_file, full_path, shallow=False):
                    print("Error: File has exact matching content found!")
                    log_event(f"Assignment {file} for {student_id}: Status: fail (file matches content)")
                    menu_function()

        print(f"Uploading {file} now...")
        time.sleep(2)

        # Moves a copy of the file to the Submitted_Assignments_Py
        source_file = os.path.join(BASE_DIR, file)
        destination_file = os.path.join(BASE_DIR, "Submitted_Assignments_Py")

        # Copies the file, so it still remains on the base directory
        shutil.copy(source_file, destination_file)

        # Outputs success message to the user and logs the event
        print(f"Successfully uploaded {file}!")
        log_event(f"Assignment {file} for {student_id}: Status: success")
        menu_function()

    else:
        print("Error: file does not exist in base directory")
        log_event("Failed to submit assignment: file not found in base directory")
        menu_function()

def check_submitted_files_function():
    if os.path.isdir("Submitted_Assignments_Py") == False:
        print("Error: Please create Submitted_Assignments_Py first!")
        log_event("Failed to check assignment: missing Submitted_Assignments_Py directory")
        menu_function()

    # User inputs the file name
    file = input("Type the file name you want to check, including the .pdf part, and press Enter: ")

    # Variable that stores the path of the base directory and file name inputted
    check_file = os.path.join(BASE_DIR, file)

    # Checks to see whether the file exists in the base directory 
    if os.path.exists(check_file) == True:
        print("File exists in the base directory")

        # Input validation: Check for matching file names
        for files in os.listdir("Submitted_Assignments_Py"):
            if fnmatch.fnmatch(file, files):
                print("File with the same name has already been submitted. Rename it.")
                log_event("Checked submitted files: one or more files matched names")
                menu_function()
            else:
                print("No files previously submitted had a matching name.")
                log_event("Checked submitted files: no files matched names")
                menu_function()

        else:
            print("Error: file does not exist in base directory")
            log_event("Failed to submit assignment: file not found in base directory")
            menu_function()

def check_submitted_assignments_py_directory_function():
    if os.path.isdir("Submitted_Assignments_Py") == False:
        print("Error: Please create Submitted_Assignments_Py first!")
        log_event("Failed to check directory: missing Submitted_Assignments_Py directory")
        menu_function()

    else:
        print("Viewing all files in Submitted_Assignments_Py")

        # Variable that stores the file path of Submitted_Assignments_Py
        check_path = os.path.join(BASE_DIR, "Submitted_Assignments_Py")

        # Variable that stores the contents of the Submitted_Assignments_Py directory
        check_items = os.listdir(check_path)

        # For each item in check_paths, output to the user
        for items in check_items:
            print(items)

def exit_function():
    while True:
        try:
            print("Are you sure you want to exit?")
            exit_choice = input("Type Y and press Enter to confirm. Type N and press Enter to cancel. ")

            if exit_choice == "Y" or exit_choice == "y":
                log_event("User successfully exited out of the program")
                sys.exit("Exiting program now. Goodbye!")

            elif exit_choice == "N" or exit_choice == "n":
                print("Cancelled exit. You will be returned to the main menu.")
                log_event("User cancelled exit out of the program")
                menu_function()

            else:
                print("Error: not a valid choice")
                log_event("Failed to exit out of the program: invalid choice")
        
        except ValueError:
            print("Error: Invalid input!")
            log_event("Failed to exit out of the program: invalid input")

def menu_function():
    while True:
        try:
            print("====================================================================================")
            print("University Examination Board Main Menu:")
            print("1: Create Submitted_Assignments Directory")
            print("2: Submit Assignment")
            print("3: Check Submitted Files")
            print("4: Check Submitted_Assignments Directory")
            print("5: Exit")
            print("====================================================================================")
    
            choice = int(input("Please type in a valid number, and hit Enter to select a choice: "))

            if choice == 1:
                create_submitted_assignments_py_directory_function()

            elif choice == 2:
                submit_assignment_function()

            elif choice == 3:
                check_submitted_files_function()

            elif choice == 4:
                check_submitted_assignments_py_directory_function()

            elif choice == 5:
                exit_function()

            else:
                print("Error: not a valid menu choice")
            
        except ValueError:
            print("Error: Invalid input!")

login_menu_function()