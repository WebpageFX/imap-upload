#!/bin/bash

# IMAP Upload Script
# Usage: ./upload_emails.sh -e EMAIL -p PASSWORD -s SERVER -P PORT -b BOX -f MBOX_FILE

# Default values
EMAIL=""
PASSWORD=""
SERVER=""
PORT=""
BOX="INBOX"
MBOX_FILE=""
SSL=""
GMAIL=""
OFFICE365=""
FASTMAIL=""
RECURSIVE=""
ERROR_FILE=""
TEST_CONNECTION=""

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -e, --email EMAIL       Email address"
    echo "  -p, --password PASSWORD Password"
    echo "  -s, --server SERVER     IMAP server hostname"
    echo "  -P, --port PORT         IMAP server port"
    echo "  -b, --box BOX           Destination mailbox (default: INBOX)"
    echo "  -f, --file MBOX_FILE    Mbox file to upload"
    echo "  -r, --recursive         Recursively upload mbox folders"
    echo "  --ssl                   Use SSL connection"
    echo "  --gmail                 Use Gmail settings (imap.gmail.com:993 SSL)"
    echo "  --office365             Use Office 365 settings (outlook.office365.com:993 SSL)"
    echo "  --fastmail              Use Fastmail settings (imap.fastmail.com:993 SSL)"
    echo "  --error ERROR_FILE      Error output file for failed messages"
    echo "  --test-connection       Test connection and list mailboxes (no upload)"
    echo "  -h, --help              Display this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -e user@example.com -p password -s imap.example.com -P 993 --ssl -f emails.mbox"
    echo "  $0 --gmail -e user@gmail.com -p password -b imported -f emails.mbox"
    echo "  $0 --office365 -e user@company.com -p password -r -f /path/to/mbox/folder"
    echo "  $0 --gmail -e user@gmail.com -p password --test-connection"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--email)
            EMAIL="$2"
            shift 2
            ;;
        -p|--password)
            PASSWORD="$2"
            shift 2
            ;;
        -s|--server)
            SERVER="$2"
            shift 2
            ;;
        -P|--port)
            PORT="$2"
            shift 2
            ;;
        -b|--box)
            BOX="$2"
            shift 2
            ;;
        -f|--file)
            MBOX_FILE="$2"
            shift 2
            ;;
        -r|--recursive)
            RECURSIVE="-r"
            shift
            ;;
        --ssl)
            SSL="--ssl"
            shift
            ;;
        --gmail)
            GMAIL="--gmail"
            shift
            ;;
        --office365)
            OFFICE365="--office365"
            shift
            ;;
        --fastmail)
            FASTMAIL="--fastmail"
            shift
            ;;
        --error)
            ERROR_FILE="--error $2"
            shift 2
            ;;
        --test-connection)
            TEST_CONNECTION="--list_boxes"
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Check required parameters
if [[ -z "$EMAIL" ]]; then
    echo "Error: Email address is required"
    usage
    exit 1
fi

if [[ -z "$PASSWORD" ]]; then
    echo "Error: Password is required"
    usage
    exit 1
fi

# If testing connection, mbox file is not required
if [[ -z "$TEST_CONNECTION" ]] && [[ -z "$MBOX_FILE" ]]; then
    echo "Error: Mbox file is required (unless using --test-connection)"
    usage
    exit 1
fi

# Build the command
CMD="python imap_upload.py"

# Add email provider shortcuts
if [[ -n "$GMAIL" ]]; then
    CMD="$CMD $GMAIL"
elif [[ -n "$OFFICE365" ]]; then
    CMD="$CMD $OFFICE365"
elif [[ -n "$FASTMAIL" ]]; then
    CMD="$CMD $FASTMAIL"
else
    # Add manual server settings if no provider shortcut
    if [[ -n "$SERVER" ]]; then
        CMD="$CMD --host $SERVER"
    fi
    if [[ -n "$PORT" ]]; then
        CMD="$CMD --port $PORT"
    fi
    if [[ -n "$SSL" ]]; then
        CMD="$CMD $SSL"
    fi
fi

# Add other options
CMD="$CMD --user \"$EMAIL\" --password \"$PASSWORD\" --box \"$BOX\""

if [[ -n "$RECURSIVE" ]]; then
    CMD="$CMD $RECURSIVE"
fi

if [[ -n "$ERROR_FILE" ]]; then
    CMD="$CMD $ERROR_FILE"
fi

if [[ -n "$TEST_CONNECTION" ]]; then
    CMD="$CMD $TEST_CONNECTION"
    echo "Testing connection to IMAP server..."
else
    # Add the mbox file only if not testing connection
    CMD="$CMD $MBOX_FILE"
fi

echo "Executing: $CMD"
echo ""

# Execute the command
eval $CMD 