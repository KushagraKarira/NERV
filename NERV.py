import os
import shutil

# Define the NERV ASCII art
NERV_ASCII = """
 ▄▄        ▄     ▄▄▄▄▄▄▄▄▄▄▄     ▄▄▄▄▄▄▄▄▄▄▄     ▄               ▄    
▐░░▌      ▐░▌   ▐░░░░░░░░░░░▌   ▐░░░░░░░░░░░▌   ▐░▌             ▐░▌   
▐░▌░▌     ▐░▌   ▐░█▀▀▀▀▀▀▀▀▀    ▐░█▀▀▀▀▀▀▀█░▌    ▐░▌           ▐░▌    
▐░▌▐░▌    ▐░▌   ▐░▌             ▐░▌       ▐░▌     ▐░▌         ▐░▌     
▐░▌ ▐░▌   ▐░▌   ▐░█▄▄▄▄▄▄▄▄▄    ▐░█▄▄▄▄▄▄▄█░▌      ▐░▌       ▐░▌      
▐░▌  ▐░▌  ▐░▌   ▐░░░░░░░░░░░▌   ▐░░░░░░░░░░░▌       ▐░▌     ▐░▌       
▐░▌   ▐░▌ ▐░▌   ▐░█▀▀▀▀▀▀▀▀▀    ▐░█▀▀▀▀█░█▀▀         ▐░▌   ▐░▌        
▐░▌    ▐░▌▐░▌   ▐░▌             ▐░▌     ▐░▌           ▐░▌ ▐░▌         
▐░▌     ▐░▐░▌ ▄ ▐░█▄▄▄▄▄▄▄▄▄  ▄ ▐░▌      ▐░▌  ▄        ▐░▐░▌        ▄ 
▐░▌      ▐░░▌▐░▌▐░░░░░░░░░░░▌▐░▌▐░▌       ▐░▌▐░▌        ▐░▌        ▐░▌
 ▀        ▀▀  ▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀  ▀         ▀  ▀          ▀          ▀ 
                                                                    
"""

# Function to calculate terminal width
def get_terminal_width():
    return shutil.get_terminal_size().columns

# Function to print the NERV ASCII art centered
def print_nerv_ascii():
    width = (get_terminal_width() - len(NERV_ASCII)) // 2
    print(" " * width + NERV_ASCII)

# Function to import from Google Contacts CSV
def import_google_contacts():
    print("Importing Google Contacts...")
    import_folder = "import"
    # Create the import folder if it doesn't exist
    os.makedirs(import_folder, exist_ok=True)
    print("Created import folder.")

    # Iterate over files in the import folder
    for filename in os.listdir(import_folder):
        csv_file = os.path.join(import_folder, filename)
        # Check if the file exists and is readable
        if os.path.isfile(csv_file) and os.access(csv_file, os.R_OK):
            print(f"Processing file: {csv_file}")
            # Create a directory to store the split files
            os.makedirs("data", exist_ok=True)
            print("Created data folder.")
            # Read the CSV file line by line and split based on the first character of the email
            with open(csv_file) as f:
                for line in f.readlines()[1:]:
                    fields = line.strip().split(',')
                    name = fields[0]
                    email = fields[30]
                    phone = fields[56]
                    city = fields[45]
                    country = fields[46]
                    address = fields[53]
                    birthday = fields[15]
                    # Extract the first character of the email
                    first_char = email[0].lower()
                    # Create directory based on first character
                    dir_path = os.path.join("data", first_char)
                    os.makedirs(dir_path, exist_ok=True)
                    print(f"Created directory: {dir_path}")
                    # Write the data to corresponding file
                    file_path = os.path.join(dir_path, f"{email}.csv")
                    with open(file_path, "a") as out_file:
                        out_file.write(f"{name},{email},{phone},{city},{country},{address},{birthday}\n")
                    print(f"Written to file: {file_path}")
        else:
            print(f"File not found or not readable: {csv_file}")

# Function to handle user input and search for person details
def handle_search():
    print("Searching for person details...")
    email = input("Enter Email: ")
    # Extract the first character of the email
    first_char = email[0].lower()
    print(f"First character of email: {first_char}")
    # Check if the directory for the first character exists
    if os.path.isdir(f"data/{first_char}"):
        print("Directory found.")
        # Search for the person with the given email ID in the corresponding directory
        file_path = f"data/{first_char}/{email}.csv"
        if os.path.isfile(file_path):
            print(f"File found: {file_path}")
            # Display person details
            display_person_details(file_path)
        else:
            print(f"Person with email {email} not found.")
    else:
        print(f"No data imported for email {email}.")

# Function to display person details as a table
def display_person_details(file_path):
    print("Displaying person details...")
    # Display table header
    print(f"{'Name':<20} | {'Email':<20} | {'Phone':<20} | {'City':<20} | {'Country':<20} | {'Address':<20} | {'Birthday':<20}")
    # Read and display person details from file
    with open(file_path) as f:
        for line in f:
            name, email, phone, city, country, address, birthday = line.strip

