#!/bin/bash
# Create a file with tmux sessions
# It will prompt different steps to create the session scripts

# Array to hold session scripts
session_scripts=()

# Ask if the user needs to set up frontend and backend in separate repositories
declare -a session_types

while true; do
    read -p "Do you need to set up frontend and backend in separate repositories? (y/n): " fb_choice
    case $fb_choice in
        [Yy]* )
            session_types=("frontend" "backend")
            break
            ;;
        [Nn]* )
            session_types=("default")
            break
            ;;
        * ) echo "Please answer y or n.";;
    esac
done

# Loop over the session types
for session_type in "${session_types[@]}"; do

    # Ask for the session name (in while loop, until it is not empty)
    while true; do
        if [ "$session_type" == "default" ]; then
            read -p "Enter the session name: " session_name
        else
            read -p "Enter the session name for $session_type: " session_name
        fi
        if [ -z "$session_name" ]; then
            echo "Session name cannot be empty"
        else
            break
        fi
    done

    # Ask for the target directory for the session
    while true; do
        read -p "Enter the target directory for the session (leave empty for current directory): " session_dir
        if [ -z "$session_dir" ]; then
            session_dir="$PWD"
            break
        elif [ -d "$session_dir" ]; then
            break
        else
            echo "Directory does not exist. Please enter a valid directory."
        fi
    done

    # Ask for the number of windows to create, or use the default setup
    # Default setup: 1 - neovim, 2 - shell for git, 3 - shell for running (npm run dev, php artisan serve, etc), 4 - random shell for other tasks

    while true; do
        read -p "Do you want to use the default setup? (y/n): " default_setup
        case $default_setup in
            [Yy]* )
                windows=("neovim" "git" "run" "shell")
                break
                ;;
            [Nn]* )
                windows=()
                break
                ;;
            * ) echo "Please answer y or n.";;
        esac
    done

    if [ ${#windows[@]} -eq 0 ]; then
        # Ask for the number of windows to create
        while true; do
            read -p "Enter the number of windows to create: " number_of_windows
            if [[ $number_of_windows =~ ^[0-9]+$ ]]; then
                break
            else
                echo "Please enter a valid number"
            fi
        done

        # Ask for the window names
        for ((i=1; i<=number_of_windows; i++)); do
            while true; do
                read -p "Enter the name for window $i: " window_name
                if [ -z "$window_name" ]; then
                    echo "Window name cannot be empty"
                else
                    windows+=("$window_name")
                    break
                fi
            done
        done
    fi

    # Ask for the commands and directories to run in each window, if any
    commands=()
    directories=()
    for window in "${windows[@]}"; do
        # Default command and directory
        command_list=()
        dir="$session_dir"

        # Check for special windows
        case $window in
            "neovim" )
                command_list=("nvim .")
                ;;
            "git" )
                command_list=("")
                ;;
            "run" )
                echo "Enter the commands to run in window '$window'. Press Enter on an empty line to finish."
                while true; do
                    read -p "> " command
                    if [ -z "$command" ]; then
                        if [ ${#command_list[@]} -eq 0 ]; then
                            echo "You must enter at least one command for '$window'."
                        else
                            break
                        fi
                    else
                        command_list+=("$command")
                    fi
                done
                ;;
            * )
                while true; do
                    read -p "Do you want to specify a different directory for window '$window'? (y/n): " dir_choice
                    case $dir_choice in
                        [Yy]* )
                            while true; do
                                read -p "Enter the directory for window '$window': " dir_input
                                if [ -d "$dir_input" ]; then
                                    dir="$dir_input"
                                    break
                                else
                                    echo "Directory does not exist. Please enter a valid directory."
                                fi
                            done
                            break
                            ;;
                        [Nn]* )
                            break
                            ;;
                        * ) echo "Please answer y or n.";;
                    esac
                done

                echo "Enter the commands to run in window '$window'. Press Enter on an empty line to finish."
                while true; do
                    read -p "> " command
                    if [ -z "$command" ]; then
                        break
                    else
                        command_list+=("$command")
                    fi
                done
                ;;
        esac
        commands+=("$(printf "%s;" "${command_list[@]}")")
        directories+=("$dir")
    done

    # Create the session script, set name to lowercase session name _tmux_session.sh
    session_script="${session_name}_tmux_session.sh"

    # Write the session script using a here-document to prevent variable expansion issues
    cat << EOF > "$session_script"
#!/bin/bash
# Create a tmux session with the name $session_name
SESSION_NAME="$session_name"
SESSION_EXISTS=\$(tmux list-sessions | grep -o "^\\\$SESSION_NAME:")

if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    cd "SESSION_DIR_PLACEHOLDER"
    tmux new-session -d -s "$SESSION_NAME"
EOF
    # Loop over the windows, assign the window name and run the commands
    for ((i=0; i<${#windows[@]}; i++)); do
        window="${windows[$i]}"
        command="${commands[$i]}"
        dir="${directories[$i]}"

        # Set the pane index (0 for the first window)
        if [ $i -eq 0 ]; then
            # Rename the first window
            cat << EOF >> "$session_script"
    tmux rename-window -t "\$SESSION_NAME:0" "$window"
EOF
        else
            # Create new windows
            cat << EOF >> "$session_script"
    tmux new-window -t "\$SESSION_NAME" -n "$window"
EOF
        fi

        # Change to the specified directory
        cat << EOF >> "$session_script"
    tmux send-keys -t "\$SESSION_NAME:$window" "cd '$dir'" C-m
EOF

        # Send the commands
        if [ -n "$command" ]; then
            IFS=';' read -ra cmd_array <<< "$command"
            for cmd in "${cmd_array[@]}"; do
                cat << EOF >> "$session_script"
    tmux send-keys -t "\$SESSION_NAME:$window" "$cmd" C-m
EOF
            done
        fi
    done

    # Close the if statement
    cat << EOF >> "$session_script"
fi
EOF

    # Append the session script to the main script file
    session_scripts+=("$session_script")

done  # End of session_types loop

# Combine all session scripts into a single script
final_script="${session_name}_tmux_all_sessions.sh"

# Start writing the final script
echo "#!/bin/bash" > "$final_script"

for script in "${session_scripts[@]}"; do
    cat "$script" >> "$final_script"
    echo "" >> "$final_script"  # Add a newline for separation
done

# Attach to the default session (first session)
first_session_name="${session_name}"
cat << EOF >> "$final_script"

tmux attach-session -t "\$SESSION_NAME"
EOF

# Make the final script executable
chmod +x "$final_script"

# Remove individual session scripts if you don't need them
for script in "${session_scripts[@]}"; do
    rm "$script"
done

echo "Session script created: $final_script"
