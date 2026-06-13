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
echo "Will create: $PROJECT_DIR"
