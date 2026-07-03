FROM ghcr.io/home-assistant/amd64-base:latest

ENV LANG=C.UTF-8 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    DJANGO_SETTINGS_MODULE=babybuddy.settings.production \
    DATABASE_URL=sqlite:////data/data/db.sqlite3 \
    MEDIA_ROOT=/data/media \
    PORT=8000

# Runtime + build deps for Pillow, psycopg, gunicorn, etc.
RUN apk add --no-cache \
      python3 \
      py3-pip \
      py3-pillow \
      jpeg \
      zlib \
      libpq \
      libffi \
      git \
      curl \
    && apk add --no-cache --virtual .build-deps \
      build-base \
      python3-dev \
      jpeg-dev \
      zlib-dev \
      libpq-dev \
      libffi-dev

WORKDIR /app

# Pin the fork ref so add-on version and code are in lockstep. Bumping
# BABYBUDDY_REV invalidates Docker's build cache so a fresh clone runs
# even when only the fork branch (not this file) moved.
ARG BABYBUDDY_REF=feature/event-images
ARG BABYBUDDY_REV=53963f2e
RUN echo "Cloning ${BABYBUDDY_REF}@${BABYBUDDY_REV}" \
    && git clone --depth 1 --branch ${BABYBUDDY_REF} \
      https://github.com/gxlabs/babybuddy.git /app \
    && pip install --break-system-packages -r requirements.txt \
    && apk del .build-deps

COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 8000
# Bypass the base image's s6-overlay init — it strips container ENV before running CMD.
ENTRYPOINT []
CMD ["/run.sh"]
