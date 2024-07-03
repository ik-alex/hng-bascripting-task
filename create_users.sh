#!/bin/bash

# Log file and password file
PASSWORD_FILE="/var/secure/user_passwords.txt"
LOG_FILE="/var/log/user_management.log"

# ensure to check if the number of argument provided is 1
# if !true exit running the entire codebase
if [ $# -ne 1 ]; then
    echo "This is how to run the script: $0 <input_textfile>" | sudo tee -a $LOG_FILE
    exit 1
fi

input_textfile=$1

# Checking if an input file to be passed as an argument exists
if [ ! -f "$input_textfile" ]; then
    echo "Error: The file $input_textfile does not exists" | sudo tee -a $LOG_FILE
    exit 1
fi

# Create necessary directories and set permissions
sudo chown root:root $PASSWORD_FILE
sudo mkdir -p /var/secure
sudo touch $PASSWORD_FILE
sudo chmod 600 $PASSWORD_FILE
sudo touch $LOG_FILE
sudo chmod 640 $LOG_FILE

generate_password() {
    < /dev/urandom tr -dc 'A-Za-z0-9!@#$%&*' | head -c 12
}

# reading input from the files
while IFS=';' read -r user groups; do
    if [ -z "$user" ] || [ -z "$groups" ]; then
        echo "Skipping invalid line: $user;$groups" | sudo tee -a $LOG_FILE
        continue
    fi

    # Create the user if they do not already exist
    if id -u "$user" >/dev/null 2>&1; then
        echo "This particular User $user exists" | sudo tee -a $LOG_FILE
    else
        sudo useradd -m "$user"
        if [ $? -eq 0 ]; then
            echo "User $user created" | sudo tee -a $LOG_FILE

            # Generating the random password for each user 
            password=$(generate_password)
            echo "$user,$password" | sudo tee -a $PASSWORD_FILE >/dev/null
            echo "$user:$password" | sudo chpasswd
            echo "User $user password is set" | sudo tee -a $LOG_FILE

            # Set appropriate permissions for the home directory
            sudo chmod 700 /home/$user
            sudo chown $user:$user /home/$user
            echo "Home directory for user $user set up with appropriate permissions" | sudo tee -a $LOG_FILE
        else
            echo "Failed to create user $user" | sudo tee -a $LOG_FILE
            continue
        fi
    fi

    # Add the user to the specified groups
    IFS=',' read -r -a group_array <<< "$groups"
    for group in "${group_array[@]}"; do
        if getent group "$group" >/dev/null 2>&1; then
            sudo usermod -aG "$group" "$user"
            echo "User $user added to existing group $group" | sudo tee -a $LOG_FILE
        else
            sudo groupadd "$group"
            sudo usermod -aG "$group" "$user"
            echo "Group $group created and user $user added to it" | sudo tee -a $LOG_FILE
        fi
    done
done < "$input_textfile"

echo "User creation and group assignment created." | sudo tee -a $LOG_FILE
