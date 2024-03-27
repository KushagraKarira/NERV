#!/bin/bash

# Define the NERV ASCII art
NERV_ASCII="
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
                                                                    
"
# Function to calculate terminal width
get_terminal_width() {
    tput cols
}

# Function to print the NERV ASCII art centered
print_nerv_ascii() {
    local width=$(( ($(get_terminal_width) - ${#NERV_ASCII}) / 2 ))
    printf "%${width}s\n" "$NERV_ASCII"
}

# Function to clear the input line
clear_input_line() {
    tput el
}

# Function to import from Google Contacts CSV
import_google_contacts() {
    local import_folder="import"
    # Create the import folder if it doesn't exist
    mkdir -p "$import_folder"
    
    # Iterate over files in the import folder
    for csv_file in "$import_folder"/*.csv; do
        # Check if the file exists and is readable
        if [ -f "$csv_file" ] && [ -r "$csv_file" ]; then
            # Create a directory to store the split files
            mkdir -p data
            # Read the CSV file line by line and split based on the first character of the email
            awk -F',' 'NR>1 {
                # Extract necessary fields
                name=$1
                email=$31
                phone=$57
                city=$46
                country=$47
                address=$54
                birthday=$16
                
                # Extract the first character of the email
                first_char=tolower(substr(email, 1, 1))
                printf "Debug: First character of email: %s\n", first_char
                
                # Create directory based on first character
                dir="data/"first_char
                printf "Debug: Directory: %s\n", dir
                system("mkdir -p \"" dir "\"")
                
                # Write the data to corresponding file
                file=dir"/"email".csv"
                printf "Debug: Writing to file: %s\n", file
                print name "," email "," phone "," city "," country "," address "," birthday > file
            }' "$csv_file"
        else
            echo "File not found or not readable: $csv_file"
        fi
    done
}


# Function to handle user input and search for person details
handle_search() {
    read -p "Enter Email: " email
    clear_input_line
    # Extract the first character of the email
    first_char=$(echo "$email" | cut -c1 | tr '[:upper:]' '[:lower:]')
    # Check if the directory for the first character exists
    if [ -d "data/$first_char" ]; then
        # Search for the person with the given email ID in the corresponding directory
        file="data/$first_char/$email.csv"
        if [ -f "$file" ]; then
            # Display person details
            display_person_details "$file"
        else
            echo "Person with email $email not found."
        fi
    else
        echo "No data imported for email $email."
    fi
}

# Function to display person details as a table
display_person_details() {
    local file="$1"
    # Display table header
    printf "%-20s | %-20s | %-20s | %-20s | %-20s | %-20s | %-20s\n" "Name" "Email" "Phone" "City" "Country" "Address" "Birthday"
    # Read and display person details from file
    while IFS=, read -r name email phone city country address birthday; do
        printf "%-20s | %-20s | %-20s | %-20s | %-20s | %-20s | %-20s\n" "$name" "$email" "$phone" "$city" "$country" "$address" "$birthday"
    done < "$file"
}

# Function to handle user choice
handle_user_choice() {
    read -p "Choose an operation (import/search/exit): " choice
    clear_input_line
    case $choice in
        "import")
            import_google_contacts
            ;;
        "search")
            handle_search
            ;;
        "exit")
            clear
            exit
            ;;
        *)
            echo "Invalid choice! Please choose again."
            handle_user_choice
            ;;
    esac
}

# Trap interrupt signals to clean up properly
trap 'clear; exit' INT

# Main loop
while true; do
    clear
    print_nerv_ascii
    handle_user_choice
    read -p "Press Enter to continue..." choice
done
