# Use python {path to the file}/task.py in powershell terminal, then press Enter to run
# For example: python C:\Users\benja\Documents\GitHub\A1_Advanced_OS\task3.py

# Initialisation: import classes when the program is run
import os
import sys

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
            print(f"Directory '{directory_name}' already exists.")
        except PermissionError:
            print(f"Permission denied: Unable to create '{directory_name}'.")
        except Exception as e:
            print(f"An error occurred: {e}")

        menu_function()

def submit_assigment_function():
    file = input("Type the file name, including the .pdf part, and press Enter:")
    check_file = BASE_DIR/file
    if check_file == True:
        print("File exists in the base directory")

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
    choice = int(input("Type in a valid integer from the main menu:"))
    print("=======================================================================================")

    if choice != 1 and choice != 2 and choice != 3 and choice != 4 and choice != 5:
        print("Error: invalid choice")
        menu_function()
    
    else:
        print("Valid option")

        if choice == 1:
             create_submitted_assigments_py_directory_function()

menu_function()