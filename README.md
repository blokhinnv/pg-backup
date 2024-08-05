# PostgreSQL Automated Backup

This project provides an automated solution for backing up PostgreSQL databases using Docker. It includes features like scheduled backups, Telegram notifications, and automatic cleanup of old backups.

## Features

- Automated daily backups of specified PostgreSQL databases
- Telegram notifications for backup status and errors
- Configurable retention policy for old backups
- Docker-based for easy deployment and portability

## Prerequisites

- Docker
- PostgreSQL database
- Telegram Bot Token and Chat ID

## Configuration

The following environment variables need to be set:

- `POSTGRES_DB`: Name of the database to backup
- `POSTGRES_HOST`: Hostname of the PostgreSQL server
- `POSTGRES_PORT`: Port of the PostgreSQL server (default: 5432)
- `POSTGRES_USER`: Username for PostgreSQL connection
- `POSTGRES_PASSWORD`: Password for PostgreSQL connection
- `BACKUP_DIR`: Directory to store backups (default: "/backups")
- `BACKUP_N_KEEP`: Number of recent backups to keep (default: 5)
- `TELEGRAM_BOT_TOKEN`: Telegram Bot Token for notifications
- `TELEGRAM_CHAT_ID`: Telegram Chat ID for notifications

## Docker Image

The Docker image is based on the official PostgreSQL image and includes:

- Python 3.11.9 (installed via pyenv)
- Required Python packages (specified in requirements.txt)
- Backup scripts (backup.sh and backup.py)

## Usage

1. Build the Docker image:
   ```
   docker build -t postgres-backup .
   ```

2. Run the container:
   ```
   docker run -d \
     -e POSTGRES_DB=your_db_name \
     -e POSTGRES_HOST=your_host \
     -e POSTGRES_USER=your_user \
     -e POSTGRES_PASSWORD=your_password \
     -e TELEGRAM_BOT_TOKEN=your_bot_token \
     -e TELEGRAM_CHAT_ID=your_chat_id \
     -v /path/to/backup/dir:/backups \
     postgres-backup
   ```

## Backup Process

- The backup script runs daily at 00:00.
- It creates a custom format dump of the specified database.
- The dump is saved in the specified backup directory with a timestamp.
- After a successful backup, old backups are cleaned up based on the `BACKUP_N_KEEP` setting.
- Notifications are sent via Telegram for successful backups, errors, and cleanup operations.

## Files

- `Dockerfile`: Defines the Docker image for the backup solution
- `backup.sh`: Shell script that checks environment variables and initiates the backup process
- `backup.py`: Python script that performs the actual backup, sends notifications, and manages old backups
- `requirements.txt`: Lists the required Python packages

## Notes
- Ensure that the PostgreSQL server is accessible from the container network.
- Make sure to secure your environment variables, especially the database credentials and Telegram tokens.