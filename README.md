# Automated Project Bootstrapping & Process Management

A "Project Factory" shell script that bootstraps the Student Attendance Tracker workspace automatically, demonstrating Infrastructure as Code principles: reproducibility, efficiency, and reliability.

## What the Script Does

setup_project.sh performs six stages:

1. User Input - prompts for a workspace name and re-prompts if empty.
2. Directory Architecture - creates the structure shown below; handles existing directories and permission errors.
3. File Generation - uses heredocs to generate all four project files.
4. Dynamic Configuration (sed) - prompts for thresholds (Warning 75%, Failure 50%), validates numeric input, edits config.json in place.
5. Process Management (Signal Trap) - a trap on SIGINT catches Ctrl+C mid-execution.
6. Environment Validation - runs python3 --version and verifies the structure.

## Directory Structure

    attendance_tracker_{input}/
        attendance_checker.py
        Helpers/
            assets.csv
            config.json
        reports/
            reports.log

## How to Run

    git clone https://github.com/acquahhh/deploy_agent_acquahhh.git
    cd deploy_agent_acquahhh
    chmod +x setup_project.sh
    ./setup_project.sh

To run the generated app:

    cd attendance_tracker_<yourname>
    python3 attendance_checker.py

## Triggering the Archive Feature (the Trap)

While the script runs, press Ctrl+C after the directory is created (e.g. at the threshold prompt). The trap will:

1. Bundle the project state into attendance_tracker_{input}_archive.tar.gz
2. Delete the incomplete directory
3. Exit with code 130

Restore later with: tar -xzf attendance_tracker_<yourname>_archive.tar.gz

## Input Validation

- Workspace name cannot be empty.
- Threshold values must be whole numbers; invalid input is re-prompted.
- Pressing Enter keeps the default value.

## Testing & Debugging

While testing, running attendance_checker.py threw KeyError: 'Names'.
The CSV had been pasted with tab/space separators instead of commas,
so Python's DictReader saw one column instead of four. I fixed the
heredoc to use proper comma-separated values, after which the script
correctly logged URGENT alerts for students below the failure threshold.
I also hit a main vs master branch mismatch and resolved it with
git branch -m master main.
## Video Walkthrough

[(https://youtu.be/h1XePEhCrt4)]

## Author

Acquahhhh - African Leadership University, Intro to Linux Summative (J26)
