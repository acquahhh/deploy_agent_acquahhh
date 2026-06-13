#!/bin/bash
# setup_project.sh - Project Factory for the attendance tracker

read -p "Enter a name for this workspace: " USER_INPUT

# 2. Re-prompt while the input is empty
while [ -z "$USER_INPUT" ]; do
    read -p "Input cannot be empty. Try again: " USER_INPUT
done

# 3. Build the names we'll use for the rest of the script
PROJECT_DIR="attendance_tracker_${USER_INPUT}"
# Signal trap - graceful handling of Ctrl+C (SIGINT)
cleanup_on_interrupt() {
    echo ""
    echo "SIGINT caught - setup cancelled by user."
    if [ -d "$PROJECT_DIR" ]; then
        echo "Bundling current state into ${ARCHIVE_NAME}.tar.gz ..."
        tar -czf "${ARCHIVE_NAME}.tar.gz" "$PROJECT_DIR"
        echo "Removing incomplete directory..."
        rm -rf "$PROJECT_DIR"
        echo "Workspace cleaned. Archive saved."
    fi
    exit 130
}
trap cleanup_on_interrupt SIGINT
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

# 6. Generate the project files
cat > "$PROJECT_DIR/attendance_checker.py" << 'EOF'
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    # 1. Load Config
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)
    
    # 2. Archive old reports.log if it exists
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    # 3. Process Data
    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
        
        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])
            
            # Simple Math: (Attended / Total) * 100
            attendance_pct = (attended / total_sessions) * 100
            
            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."
            
            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF

cat > "$PROJECT_DIR/Helpers/assets.csv" << 'EOF'
Email	Names	Attendance Count	Absence Count
alice@example.com	Alice Johnson	14	1
bob@example.com	Bob Smith	7	8
charlie@example.com	Charlie Davis	4	11
diana@example.com	Diana Prince	15	0
EOF

cat > "$PROJECT_DIR/Helpers/config.json" << 'EOF'
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}

EOF

cat > "$PROJECT_DIR/reports/reports.log" << 'EOF'
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.
EOF
echo "Project files generated."

# 7. Dynamic configuration - update thresholds with sed
CONFIG_FILE="$PROJECT_DIR/Helpers/config.json"

read -p "Update attendance thresholds? (y/N): " UPDATE
if [ "$UPDATE" = "y" ] || [ "$UPDATE" = "Y" ]; then

    read -p "New WARNING threshold [default 75]: " WARN
    WARN=${WARN:-75}
    while ! [[ "$WARN" =~ ^[0-9]+$ ]]; do
        read -p "Invalid. Enter a whole number for WARNING: " WARN
        WARN=${WARN:-75}
    done

    read -p "New FAILURE threshold [default 50]: " FAIL
    FAIL=${FAIL:-50}
    while ! [[ "$FAIL" =~ ^[0-9]+$ ]]; do
        read -p "Invalid. Enter a whole number for FAILURE: " FAIL
        FAIL=${FAIL:-50}
    done

    sed -i "s/\"warning\": [0-9]*/\"warning\": $WARN/" "$CONFIG_FILE"
    sed -i "s/\"failure\": [0-9]*/\"failure\": $FAIL/" "$CONFIG_FILE"

    echo "config.json updated: warning=$WARN, failure=$FAIL"
else
    echo "Keeping default thresholds (75/50)."
fi
