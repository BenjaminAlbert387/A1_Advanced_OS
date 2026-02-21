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

def create_submitted_assignments_py_directory_function():

        # Specify the directory name
        directory_name = "Submitted_Assignments_Py"

        # Create the directory
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
    if os.path.isdir("Submitted_Assignments_Py") == False:
        print("Error: Please create Submitted_Assignments_Py first!")
        menu_function()

    # User inputs the file name
    file = input("Type the file name, including the .pdf part, and press Enter: ")

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
                menu_function()

        # Input validation 2: Check for supported file types
        if ext_file != ".docx" and ext_file != ".pdf":
            print("Error: File type not supported")
            menu_function()

        # Input validation 3: Check if the file is over 5MB
        if size_file > 5 * 1000000:
            print("Error: File is over 5MB in size!")
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
                    menu_function()

        print(f"Uploading {file} now...")
        time.sleep(2)

        # Moves a copy of the file to the Submitted_Assignments_Py
        source_file = os.path.join(BASE_DIR, file)
        destination_file = os.path.join(BASE_DIR, "Submitted_Assignments_Py")
        shutil.copy(source_file, destination_file)

        print(f"Successfully uploaded {file}!")

    else:
        print("Error: file does not exist in base directory")

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
    
            choice = int(input("Type in a valid integer from the main menu: "))

            if choice == 1:
                create_submitted_assignments_py_directory_function()

            elif choice == 2:
                submit_assignment_function()

            else:
                print("Error: not a valid menu choice")
            
        except ValueError:
            print("Error: Invalid input!")

menu_function()