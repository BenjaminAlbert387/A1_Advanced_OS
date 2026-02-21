# Use python {path to the file}/task.py in powershell terminal, then press Enter to run
# For example: python C:\Users\benja\Documents\GitHub\A1_Advanced_OS\task3.py

# Initialisation: import classes when the program is run
import os
import sys
import fnmatch

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

def create_submitted_assigments_py_directory_function():

        # Specify the directory name
        directory_name = "Submitted_Assigments_Py"

        # Create the directory
        try:
            os.mkdir(directory_name)

            # Ouptut success message to the user
            print(f"Directory '{directory_name}' created successfully.")
        
        # Python class that is true if the directory already exists
        except FileExistsError:
            print(f"Error: Directory '{directory_name}' already exists.")
        except PermissionError:
            print(f"Error: Permission denied, unable to create '{directory_name}'.")
        except Exception as e:
            print(f"Error: Other error occurred: {e}")

        menu_function()

def submit_assigment_function():
    if os.path.isdir("Submitted_Assigments_Py") == False:
        print("Error: Please create Submitted_Assigments_Py first!")
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
        for files in os.listdir("Submitted_Assigments_Py"):
            if fnmatch.fnmatch(file, files):
                print("Error: File with the same name has already been submitted")

        # Input validation 2: Check for supported file types
        if ext_file != ".docx" or ext_file != ".pdf":
            print("Error: File type not supported")

        # Input validation 3: Check if the file is over 5MB
        if size_file > 5 * 1000000:
            print("Error: File is over 5MB in size!")
        
    else:
        print("Error: file does not exist in base directory")

def menu_function():
    print("=======================================================================================")
    print("University Examination Board Main Menu:")
    print("1: Create Submitted_Assignments Directory")
    print("2: Submit Assignment")
    print("3: Check Submitted Files")
    print("4: Check Submitted_Assignments Directory")
    print("5: Exit")
    choice = int(input("Type in a valid integer from the main menu: "))
    print("=======================================================================================")

    while True:
        try:
            choice = int(input("Enter a number: "))
            break
        except ValueError:
            print("Error: Invalid input!")

        if choice == 1:
            create_submitted_assigments_py_directory_function()

        elif choice == 2:
            submit_assigment_function()

        else:
            print("Error: not a valid menu choice")

menu_function()