#!/usr/bin/with-contenv bashio
set -e

# Persistent Django SECRET_KEY (kept in /data so it survives add-on updates).
SECRET_FILE=/data/.secretkey
if [ ! -f "${SECRET_FILE}" ]; then
    bashio::log.info "Generating a Django SECRET_KEY at ${SECRET_FILE}"
    python3 -c "import secrets; print(secrets.token_urlsafe(50))" > "${SECRET_FILE}"
fi
export SECRET_KEY="$(cat "${SECRET_FILE}")"

# User-controlled options from config.yaml.
export ALLOWED_HOSTS="$(bashio::config 'allowed_hosts')"
export CSRF_TRUSTED_ORIGINS="$(bashio::config 'csrf_trusted_origins')"
if bashio::config.true 'debug'; then
    export DEBUG=1
fi

mkdir -p /data/data /data/media
cd /app

bashio::log.info "Applying migrations..."
python3 manage.py migrate --noinput

bashio::log.info "Starting gunicorn on 0.0.0.0:${PORT:-8000}"
exec gunicorn babybuddy.wsgi:application \
    --bind "0.0.0.0:${PORT:-8000}" \
    --workers 2 \
    --timeout 60 \
    --access-logfile - \
    --error-logfile -
