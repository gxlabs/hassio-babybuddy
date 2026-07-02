#!/bin/sh
set -e

log() { echo "[babybuddy_gxlabs] $*"; }

CONFIG=/data/options.json
SECRET_FILE=/data/.secretkey

# Persistent Django SECRET_KEY (kept in /data so it survives add-on updates).
if [ ! -f "${SECRET_FILE}" ]; then
    log "Generating a Django SECRET_KEY at ${SECRET_FILE}"
    python3 -c "import secrets; print(secrets.token_urlsafe(50))" > "${SECRET_FILE}"
fi
export SECRET_KEY="$(cat "${SECRET_FILE}")"

# User-controlled options from config.yaml, written by supervisor to options.json.
if [ -f "${CONFIG}" ]; then
    export ALLOWED_HOSTS="$(python3 -c 'import json;print(json.load(open("/data/options.json")).get("allowed_hosts", "*"))')"
    export CSRF_TRUSTED_ORIGINS="$(python3 -c 'import json;print(json.load(open("/data/options.json")).get("csrf_trusted_origins", ""))')"
    DEBUG_FLAG="$(python3 -c 'import json;print(json.load(open("/data/options.json")).get("debug", False))')"
    if [ "${DEBUG_FLAG}" = "True" ]; then
        export DEBUG=1
    fi
else
    log "No /data/options.json — using defaults"
    export ALLOWED_HOSTS="*"
fi

mkdir -p /data/data /data/media
cd /app

log "Applying migrations..."
python3 manage.py migrate --noinput

log "Starting gunicorn on 0.0.0.0:${PORT:-8000}"
exec gunicorn babybuddy.wsgi:application \
    --bind "0.0.0.0:${PORT:-8000}" \
    --workers 2 \
    --timeout 60 \
    --access-logfile - \
    --error-logfile -
