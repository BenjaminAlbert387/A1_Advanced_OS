# Use python {path to the file}/task.py in powershell terminal, then press Enter to run
# For example: python C:\Users\benja\Documents\GitHub\A1_Advanced_OS\task3.py

def create_submitted_assigments_py_directory_function():
        import os

        # Specify the directory name
        directory_name = "Submitted_Assigments_Py"

        # Create the directory
        try:
            os.mkdir(directory_name)
            print(f"Directory '{directory_name}' created successfully.")
        except FileExistsError:
            print(f"Directory '{directory_name}' already exists.")
        except PermissionError:
            print(f"Permission denied: Unable to create '{directory_name}'.")
        except Exception as e:
            print(f"An error occurred: {e}")

        menu_function()

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