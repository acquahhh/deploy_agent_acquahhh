#!/bin/bash
# setup_project.sh - Project Factory for the attendance tracker

# 1. Ask the user for the workspace name
read -p "Enter a name for this workspace: " USER_INPUT

# 2. Re-prompt while the input is empty
while [ -z "$USER_INPUT" ]; do
    read -p "Input cannot be empty. Try again: " USER_INPUT
done

# 3. Build the names we'll use for the rest of the script
PROJECT_DIR="attendance_tracker_${USER_INPUT}"
ARCHIVE_NAME="attendance_tracker_${USER_INPUT}_archive"

# Temporary test line - remove later

# 4. Handle the case where the directory already exists
if [ -d "$PROJECT_DIR" ]; then
    read -p "'$PROJECT_DIR' already exists. Overwrite it? (y/N): " OVERWRITE
    if [ "$OVERWRITE" = "y" ] || [ "$OVERWRITE" = "Y" ]; then
        rm -rf "$PROJECT_DIR"
    else
        echo "Aborting to avoid overwriting existing work."
        exit 1
    fi
fi

# 5. Create the directory structure, catching permission errors
echo "Creating directory structure..."
if ! mkdir -p "$PROJECT_DIR/Helpers" "$PROJECT_DIR/reports"; then
    echo "ERROR: Could not create '$PROJECT_DIR' (permission denied?)"
    exit 1
fi

echo "Structure created successfully."
ls -R "$PROJECT_DIR"
