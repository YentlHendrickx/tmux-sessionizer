# tmux Project Launcher

## Overview
This Bash script provides an interactive way to navigate and open development project directories inside a `tmux` session. It recursively scans a base development directory (`$HOME/dev` by default), filtering out ignored patterns and distinguishing between Git repositories and non-Git directories. Users can select a project using `fzf`, and the script will either:

- Run a custom script associated with the selected directory (if configured).
- Attach to an existing `tmux` session or create a new one for Git repositories.
- Ignore non-Git repositories.

## Features
- **Recursive project discovery**: Scans `$HOME/dev` for Git repositories and non-Git directories.
- **Ignore patterns**: Reads ignored directories from an external file.
- **Custom scripts**: Allows running predefined scripts for specific projects.
- **Fuzzy search with `fzf`**: Lets users quickly find and select a directory.
- **Automatic `tmux` session management**: Attaches to or creates a session for Git repositories.
- **Ensures script is run outside `tmux`**: Prevents nested sessions.

## Requirements
- `tmux`
- `fzf`
- Bash (tested on `bash` 5.x)

## Installation
1. Copy the script to a convenient location (e.g., `~/bin/tmux_project_launcher.sh`).
2. Ensure it is executable:
   ```bash
   chmod +x ~/bin/tmux_project_launcher.sh
   ```
3. Install `fzf` and `tmux` if they are not already installed:
   ```bash
   sudo apt install fzf tmux   # Debian/Ubuntu
   sudo pacman -S fzf tmux    # Arch Linux
   brew install fzf tmux      # macOS (Homebrew)
   ```
4. (Optional) Modify the configuration paths at the beginning of the script if needed.

## Usage
Run the script from the terminal:
```bash
~/bin/tmux_project_launcher.sh
```

### Selection Workflow
1. The script will scan `$HOME/dev` for projects.
2. It will list them in an `fzf` menu.
3. Select a directory:
   - If a custom script is defined for the directory in `tmux_project_config`, it will run.
   - If the directory is a Git repository, a `tmux` session is created or attached.
   - If the directory is not a Git repository, the script exits without launching `tmux`.

## Configuration
### `tmux_project_config`
This file maps specific directories to custom scripts. Each line should be in the format:
```bash
/path/to/project=/path/to/script.sh
```
The script will be executed instead of launching `tmux` if the directory is selected.

### `ignore_patterns.txt`
A list of directory names to ignore, one per line. Lines starting with `#` are treated as comments.
Example:
```
node_modules
venv
.build
```
