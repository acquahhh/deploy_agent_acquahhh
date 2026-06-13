# Automated Project Bootstrapping & Process Management

A "Project Factory" shell script that bootstraps the **Student Attendance Tracker** workspace automatically — demonstrating Infrastructure as Code (IaC) principles: reproducibility, efficiency, and reliability.

## What the Script Does

`setup_project.sh` performs six stages:

1. **User Input** — Prompts for a workspace name and re-prompts if the input is empty.

2. **Directory Architecture** — Creates the structure:
It handles the case where the directory already exists (asks before overwriting) and exits cleanly on permission errors.

3. **File Generation** — Uses heredocs to generate all four project files inside the structure.

4. **Dynamic Configuration (sed)** — Asks whether to update the attendance thresholds (Warning default 75%, Failure default 50%). Input is validated as numeric before `sed -i` performs an in-place edit of `Helpers/config.json`.

5. **Process Management (Signal Trap)** — A `trap` on SIGINT catches Ctrl+C mid-execution. See "Triggering the Archive Feature" below.

6. **Environment Validation (Health Check)** — Runs `python3 --version` and prints a success or warning message, then verifies every file in the required structure exists.

## How to Run

```bash
git clone https://github.com/acquahhh/deploy_agent_acquahhh.git
cd deploy_agent_acquahhh
chmod +x setup_project.sh
./setup_project.sh
```

Follow the prompts: enter a workspace name, then optionally update the thresholds.

To run the generated application afterwards:

```bash
cd attendance_tracker_<yourname>
python3 attendance_checker.py
```

## Triggering the Archive Feature (the Trap)

While the script is running, press **Ctrl+C** at any point after the directory has been created (for example, at the "Update attendance thresholds?" prompt). The SIGINT trap will:

1. Bundle the current project state into `attendance_tracker_{input}_archive.tar.gz`
2. Delete the incomplete project directory to keep the workspace clean
3. Exit with code 130 (the conventional SIGINT exit code)

To restore the archived state later:

```bash
tar -xzf attendance_tracker_<yourname>_archive.tar.gz
```

## Input Validation

- The workspace name cannot be empty.
- Threshold values must be whole numbers; anything else is rejected and re-prompted.
- Pressing Enter at a threshold prompt keeps the default value.

## Video Walkthrough

[Add your video link here]

## Author

Acquahhhh — African Leadership University, Intro to Linux Summative (J26)
