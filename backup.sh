#!/bin/bash
if [ "${POSTGRES_DB}" = "**None**" ]; then
  echo "You need to set the POSTGRES_DB or POSTGRES_DB_FILE environment variable."
  exit 1
fi

if [ "${POSTGRES_USER}" = "**None**" ]; then
  echo "You need to set the POSTGRES_USER environment variable."
  exit 1
fi

if [ "${POSTGRES_HOST}" = "**None**" ]; then
  echo "You need to set the POSTGRES_HOST environment variable."
  exit 1
fi

if [ "${POSTGRES_PASSWORD}" = "**None**" ]; then
  echo "You need to set the POSTGRES_PASSWORD environment variable."
  exit 1
fi

if [ "${POSTGRES_PORT}" = "**None**" ]; then
  echo "You need to set the POSTGRES_PORT environment variable."
  exit 1
fi

if [ "${TELEGRAM_BOT_TOKEN}" = "**None**" ]; then
  echo "You need to set the TELEGRAM_BOT_TOKEN environment variable."
  exit 1
fi

if [ "${TELEGRAM_CHAT_ID}" = "**None**" ]; then
  echo "You need to set the TELEGRAM_CHAT_ID environment variable."
  exit 1
fi


export PGUSER="${POSTGRES_USER}"
export PGPASSWORD="${POSTGRES_PASSWORD}"
export PGHOST="${POSTGRES_HOST}"
export PGPORT="${POSTGRES_PORT}"

source ~/.bashrc
python ./backup.py