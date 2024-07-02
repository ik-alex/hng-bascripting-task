## I signup for an internship program named HNG. It is expected that the intern should have an intermidate to advance experience for any track they wish to participate in. For more information regarding the internship, your can follow this link https://hng.tech/internship and applying for a job tou can also checkout this link  https://hng.tech/hire.

### Task 1: We were taksed to write a script named ```create_user.sh``` for creating a user and adding the user to a group via reading from an input file

---

```
#!/bin/bash
# Log file and password file
PASSWORD_FILE="/var/secure/user_passwords.txt"
LOG_FILE="/var/log/user_management.log"
# ensure to check if the number of argument provided is 1
# if !true exit running the entire codebase
if [ $# -ne 1 ]; then
    echo "Usage: $0 <input_textfile>" | sudo tee -a $LOG_FILE
    exit 1
fi
```
```#!/bin/bash``` 
the shebang decalaration specifying that this file is a bash script

```
PASSWORD_FILE="/var/secure/user_passwords.txt"
LOG_FILE="/var/log/user_management.log"
``` 
the above block of code assigns the path ```/var/secure/user_passwords.txt``` to variable ```PASSWORD_FILE``` and path ```/var/log/user_management.log``` to variable ```LOG_FILE```

```
if [ $# -ne 1 ]; then
    echo "This is how to run the script: $0 <input_textfile>" | sudo tee -a $LOG_FILE
    exit 1
fi
```
1. `if [ $# -ne 1 ]; then`
- `if` starts the conditional statement <br>
- `$# -ne 1` `$#` is a speacial variable that holds the number of argument passed to a script. This line checks if the number of argument is not equal(-ne) to 1 <br>
2. `echo "This is how to run the script: $0 <input_textfile>" | sudo tee -a $LOG_FILE`: <br>
- `echo "This is how to run the script: $0 <input_textfile>` prints out the message to the terminal. <br>
  - `$0` this variable holds the name of the script. in our case it is `create_user.sh`. <br>
- `| sudo tee -a $LOG_FILE` this pipes the out of the echo command to the `tee` command <br>
  - `-a` appends the output the variable `$LOG_FILE` <br>
3. `exit 1`:
- `exit`: exits the script
- `1` this is an exit status code
- `fi` end of if statement
4. `input_textfile=$1`:
- `input_textfile=$1` assigns the first argument passed to script($1) to the variable `input_textfile`
- `$1` a speacial variable that holds the first argument to the script.

```
#confirm if an input file passed as an argument to the script exists
if [ ! -f "$input_textfile" ]; then
    echo "Error: The file $input_textfile does not exists" | sudo tee -a $LOG_FILE
    exit 1
fi
```
1. `if [ ! -f "$input_textfile" ]; then`:
    - `if` this starts the conditional statement
    - `[ ! -f "$input_textfile" ]` this line of script checks if the specified file variable `$input_textfile` exists
      - `!` is a logical NOT statement
      - `$input_textfile` variable holding the file name
2. `echo "Error: The file $input_textfile does not exists" | sudo tee -a $LOG_FILE` 
   - `echo "Error: The file $input_textfile does not exists"` prints the output to the terminal
   - `| sudo tee -a $LOG_FILE` this pipes the out of the echo command to the `tee` command
   - `-a` appends the output the variable `$LOG_FILE`
3. `exit 1`:
   - `exit`: exits the script
   - `1` this is an exit status code
   - `fi` end of if statement

```
generate_password() {
    < /dev/urandom tr -dc 'A-Za-z0-9!@#$%&*' | head -c 12
}
```
This is the function that generates the random password. <br>


```
#this block of script starts reading scripts from the file
while IFS=';' read -r user groups; do
    if [ -z "$user" ] || [ -z "$groups" ]; then
        echo "Skipping invalid line: $user;$groups" | sudo tee -a $LOG_FILE
        continue
    fi
```
1. `while IFS=';' read -r user groups; do`:
    - `while` this starts the loop
    - `IFS=';'` this sets the internal field separator to ';' which implies that the `read` command splits the line to separate fields based on the semicolon
    - `read -r user groups` reads each line form the input file and assigns the first field to the variable user and the subsequent field after the ; to the group variable
    - `do` begins the block of the code to execute each iteration of the code
2. `if [ -z "$user" ] || [ -z "$groups" ]; then`
    - `[ -z "$user" ]` checks if the $user variable is empty
    - `-z` test if the length of the string is zero
    - `||` logical OR operator
    - `[ -z "$groups" ]` checks if the $groups variable is empty
    - `then` execute the following code if the condition holds true
    - `echo "Skipping invalid line: $user;$groups" ` prints a message if the current line is invalid due to missing user and groups
    - `| sudo tee -a $LOG_FILE` pipes the echo output and appends the output as an input to the `$LOG_FILE`
    - `continue` skips the current loop iteration and proceeds to the next loop iteration
    - `fi` end of the if statement

### This next block of code create user if they do not exist, and also creates a directory for the user
```
    # Create the user if they do not already exist
    if id -u "$user" >/dev/null 2>&1; then
         echo "This particular User $user exists" | sudo tee -a $LOG_FILE
    else
        sudo useradd -m "$user"
        if [ $? -eq 0 ]; then
            echo "User $user created" | sudo tee -a $LOG_FILE

            # Generate a random password for the user
            password=$(generate_password)
            echo "$user,$password" | sudo tee -a $PASSWORD_FILE >/dev/null
            echo "$user:$password" | sudo chpasswd
            echo "Password for user $user set" | sudo tee -a $LOG_FILE

            # Set appropriate permissions for the home directory
            sudo chmod 700 /home/$user
            sudo chown $user:$user /home/$user
            echo "Home directory for user $user set up with appropriate permissions" | sudo tee -a $LOG_FILE
        else
            echo "Failed to create user $user" | sudo tee -a $LOG_FILE
            continue
        fi
    fi
```
1. `if id -u "$user" >/dev/null 2>&1;`
   - `if` the conditional selector
   - `id -u "$user"` this gets the id of the user variable to confirm if it exists
   - `>/dev/null 2>&1` this redirects the standard output or standard error to `/dev/null`
   - `echo "This particular User $user exists"` this prints the output to the terminal
   - `| sudo tee -a $LOG_FILE` pipes the echo output and appends the output as an input to the `$LOG_FILE`
2. `sudo useradd -m "$user"` this creates the user in the `$user` variable in the home directory with a sudo permission.
3. `if [ $? -eq 0 ]; then`
   - `if` the conditional selector
   - `[ $? -eq 0 ]` this checks if the previous command was executed successfully. in this case the previous command is `sudo useradd -m "$user"`
   - `$?` holds the exit status of the previous command
   - `0` indicates success of the execution
4. `echo "User $user created" | sudo tee -a $LOG_FILE` prints out the status of the excuted command and log it into the `$LOG_FILE`
5. `password=$(generate_password)` this line calls the generate_password and adds the generated password to the password variable
6. `echo "$user,$password" | sudo tee -a $PASSWORD_FILE >/dev/null` this saves the username and password to a file and suppress the output from showin in the terminal
7. `echo "$user:$password" | sudo chpasswd` this changes the password of the user
8. `sudo chmod 700 /home/$user` sets the home directory of the user to full permission
9. `sudo chown $user:$user /home/$user` changes the ownership of the home directory to user.
10. `else` if the condition doest hold it will print out the error message of unable to create user

### The next block of code is to add the users to a group
```
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
```
   - `IFS=',' read -r -a group_array <<< "$groups"`
   - `IFS=','`: Sets the Internal Field Separator to a comma. This means the read command will split the input string based on commas.
   - `read -r -a group_array <<< "$groups"` Reads the group variable, splits it by comma and stores the value to the group_array.
   - `for group in "${group_array[@]}"` this loops through the `group_array` array and stores each iteration to group.
   - `if getent group "$group" >/dev/null 2>&1` if the group exists in the system; also suppress the standard output and error.
   - `sudo usermod -aG "$group" "$user"` adds users to the existing group
   - `sudo groupadd "$group"` this creates a new group.
   - `sudo usermod -aG "$group" "$user"` this adds user to the group
   - `echo "Group $group created and user $user added to it" | sudo tee -a $LOG_FILE` prints the output and log it into the log file.
   - `done` ends the for loop
   - `done < "$input_textfile"` ends the while loop that reads from the input file.
   - `echo "User creation and group assignment created." | sudo tee -a $LOG_FILE` outputing the finished the creation of users and group.# HNG-Task-1
### Hng-Task-1-Script
