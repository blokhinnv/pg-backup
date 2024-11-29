from functools import partial
import glob
import os
import subprocess
import time
from datetime import datetime

import requests
import schedule
from loguru import logger


# Function to send Telegram message
def send_telegram_message(message):
    bot_token = os.environ.get("TELEGRAM_BOT_TOKEN")
    chat_id = os.environ.get("TELEGRAM_CHAT_ID")

    if not bot_token or not chat_id:
        logger.info("Telegram credentials not set in environment variables")
        return

    url = f"https://api.telegram.org/bot{bot_token}/sendMessage"
    payload = {"chat_id": chat_id, "text": message}

    try:
        response = requests.post(url, json=payload)
        response.raise_for_status()
        logger.info(message)
        logger.info("Telegram message sent successfully")
    except requests.exceptions.RequestException as e:
        logger.info(f"Failed to send Telegram message: {e}")


def clean_old_dumps(db_name, is_weekly=False):
    # Get list of dump files for this database
    backup_dir = os.environ.get("BACKUP_DIR", "/backups")
    dump_files = glob.glob(f"{backup_dir}/{db_name}_{'weekly_' if is_weekly else ''}*.custom")

    # Sort files by modification time (newest first)
    dump_files.sort(key=os.path.getmtime, reverse=True)
    keep = int(os.environ.get("BACKUP_N_KEEP", "5"))
    # Remove old files
    for old_file in dump_files[keep:]:
        try:
            os.remove(old_file)
            send_telegram_message(f"Deleted old dump: {old_file}")
        except OSError as e:
            logger.info(f"Error deleting {old_file}: {e}")


# Function to perform database dump
def perform_db_dump(is_weekly=False):
    db_name = os.environ.get("POSTGRES_DB")
    if not db_name:
        send_telegram_message("Error: POSTGRES_DB environment variable not set")
        return

    backup_dir = os.environ.get("BACKUP_DIR", "/backups")
    timestamp = datetime.now().strftime("%Y_%m_%d_%H_%M_%S")

    file_name = f"{backup_dir}/{db_name}_{'weekly_' if is_weekly else ''}{timestamp}.custom"

    try:
        subprocess.run(
            ["pg_dump", "-d", db_name, "-f", file_name, "-F", "c"],
            check=True,
        )
        send_telegram_message(f"Database dump successful: {file_name}")

        # Clean old dumps after successful new dump
        clean_old_dumps(db_name, is_weekly)
    except subprocess.CalledProcessError as e:
        send_telegram_message(f"Error during database dump: {e}")


if __name__ == "__main__":
    perform_db_dump()
    # Schedule the task
    schedule.every().day.at("00:00").do(perform_db_dump)

    # Schedule the weekly task (every Monday at 00:00)
    perform_weekly_db_dump = partial(perform_db_dump, is_weekly=True)
    schedule.every().monday.at("00:00").do(perform_weekly_db_dump, is_weekly=True)

    # Run the script indefinitely
    while True:
        schedule.run_pending()
        time.sleep(1)
