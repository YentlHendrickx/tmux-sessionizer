#!/usr/bin/env bash

CONFIG_FILE="/home/haze/dev/tools/tmux/tmux_project_config"
IGNORE_FILE="/home/haze/dev/tools/tmux/ignore_patterns.txt"

BASE_DIR="$HOME/dev"
START_DIR="$(pwd)"

if [[ -n "$TMUX" ]]; then
    echo "Please run this script outside of tmux."
    exit 1
fi

#######################################
# Checks if a directory has a .git/ folder
#######################################
is_git_repo() {
    [[ -d "$1/.git" ]]
}

#######################################
# Pull a custom script path from $CONFIG_FILE, if it exists
#######################################
get_script_for_dir() {
    local dir="$1"
    if [[ -f "$CONFIG_FILE" ]]; then
        grep -F "$dir=" "$CONFIG_FILE" | cut -d= -f2-
    else
        echo ""
    fi
}

#######################################
# Create or attach a tmux session
#######################################
create_or_attach_tmux_session() {
    local dir="$1"
    local session_name
    session_name=$(basename "$dir")  # use directory name as session name

    if tmux has-session -t "$session_name" 2>/dev/null; then
        echo "Attaching to existing tmux session: $session_name"
        tmux attach-session -t "$session_name"
    else
        echo "Creating new tmux session for: $dir"
        tmux new-session -d -s "$session_name" -c "$dir"
        tmux rename-window -t "$session_name:0" "shell"
        tmux send-keys  -t "$session_name:0" "cd '$dir'" C-m
        tmux attach-session -t "$session_name"
    fi
}

#######################################
# Read ignore patterns. We'll compare each directory's basename
# to these patterns. If it matches, we skip that directory entirely.
#######################################
should_ignore() {
    local dir="$1"
    local base
    base=$(basename "$dir")

    while IFS= read -r pattern; do
        [[ -z "$pattern" || "$pattern" == \#* ]] && continue

        if [[ "$base" == "$pattern" ]]; then
            return 0  # "yes, ignore"
        fi
    done < "$IGNORE_FILE"

    return 1  # "do not ignore"
}

#######################################
# Arrays to store non-git directories and git repos
#######################################
declare -a non_git_dirs=()
declare -a git_repos=()

#######################################
# Recursively explore the directory tree:
#  - If `dir` is a git repo, add it to git_repos and stop.
#  - Else, add `dir` to non_git_dirs, then recurse into children.
#  - Skip if `should_ignore` is true.
#######################################
collect_dirs() {
    local dir="$1"

    if should_ignore "$dir"; then
        return
    fi

    if is_git_repo "$dir"; then
        git_repos+=( "$dir" )
        return
    fi

    non_git_dirs+=( "$dir" )

    local child
    for child in "$dir"/*; do
        [[ -d "$child" ]] || continue
        collect_dirs "$child"
    done
}

#######################################
# MAIN: gather directories, then build fzf display
#######################################
for topdir in "$BASE_DIR"/*; do
    [[ -d "$topdir" ]] || continue
    collect_dirs "$topdir"
done

# Now we have two arrays:
#   git_repos[] and non_git_dirs[]
# Let's unify them in whichever order you want:
#   all_dirs = git_repos first, then non-git (or vice versa)
# Depending on your preference:
all_dirs=( "${git_repos[@]}" "${non_git_dirs[@]}" )

#-------------------------------------------
# Build an array of lines to show in fzf, each annotated if there's a script
#-------------------------------------------
fzf_entries=()
for dir in "${all_dirs[@]}"; do
    script_path="$(get_script_for_dir "$dir")"
    if [[ -n "$script_path" && -x "$script_path" ]]; then
        # Add a tab or some delimiter plus label
        fzf_entries+=( "${dir}   [SCRIPT: ${script_path}]" )
    else
        fzf_entries+=( "$dir" )
    fi
done

#-------------------------------------------
# Run fzf
#-------------------------------------------
selected_line=$(
    printf '%s\n' "${fzf_entries[@]}" \
    | fzf --prompt="Select a directory: "
)

if [[ -z "$selected_line" ]]; then
    echo "No directory selected. Exiting."
    cd "$START_DIR"
    exit 1
fi

#-------------------------------------------
# Extract the actual directory path from selected_line
# We'll split by Double space
#-------------------------------------------
selected_dir="${selected_line%%  *}"

echo "Selected directory: $selected_dir"

#-------------------------------------------
# Run script or tmux
#-------------------------------------------
script="$(get_script_for_dir "$selected_dir")"
if [[ -n "$script" && -x "$script" ]]; then
    echo "Running custom script for directory: $selected_dir"
    "$script"
else
    if is_git_repo "$selected_dir"; then
        echo "Directory is a Git repository. Creating/Attaching tmux session."
        create_or_attach_tmux_session "$selected_dir"
    else
        echo "Directory is not a Git repository. Exiting."
        cd "$START_DIR"
    fi
fi
