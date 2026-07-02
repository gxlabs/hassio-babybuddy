ARG BUILD_FROM
FROM ${BUILD_FROM}

ENV LANG=C.UTF-8 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    DJANGO_SETTINGS_MODULE=babybuddy.settings.production \
    DATABASE_URL=sqlite:////data/data/db.sqlite3 \
    MEDIA_ROOT=/data/media \
    PORT=8000

# The HA add-on base image is Alpine-flavored; install runtime + build deps.
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

# Pin the fork ref so add-on version and code are in lockstep.
ARG BABYBUDDY_REF=feature/event-images
RUN git clone --depth 1 --branch ${BABYBUDDY_REF} \
      https://github.com/gxlabs/babybuddy.git /app \
    && pip install --break-system-packages -r requirements.txt \
    && apk del .build-deps

COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 8000
CMD ["/run.sh"]
