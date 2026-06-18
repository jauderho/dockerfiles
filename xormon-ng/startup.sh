#!/bin/bash
set -e

APPDIR=/home/xormon/xormon-ng
ENVFILE="$APPDIR/server-nest/.env"

if [ -f /firstrun ]; then
    echo "Running for the first time.. need to configure..."

    # timezone (default UTC, overridable via TIMEZONE env var)
    : "${TIMEZONE:=Etc/UTC}"
    echo "${TIMEZONE}" > /etc/timezone
    ln -sf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime || true

    # (re)generate server-nest/.env from environment variables. The tarball
    # ships a stub .env (NODE_ENV=production only), so we always overwrite it
    # on first run with the real DB config. An external TimescaleDB (PostgreSQL
    # + TimescaleDB) is required - point DB_HOST/DB_PASSWORD at it. Set
    # APP_SECRET for stable sessions across container recreation (a random one
    # is generated otherwise).
    : "${APP_PORT:=8443}"
    : "${DB_HOST:=127.0.0.1}"
    : "${DB_PORT:=5432}"
    : "${DB_USERNAME:=postgres}"
    : "${DB_DATABASE:=xormon}"
    : "${DB_PASSWORD:=}"
    : "${APP_SECRET:=$(head -c 32 /dev/urandom | base64 | tr -d '\n=/+')}"

    cat > "$ENVFILE" <<EOF
NODE_ENV=production
DOCKER=1
APP_PORT=${APP_PORT}
DB_HOST=${DB_HOST}
DB_PORT=${DB_PORT}
DB_USERNAME=${DB_USERNAME}
DB_DATABASE=${DB_DATABASE}
DB_PASSWORD=${DB_PASSWORD}
APP_SECRET=${APP_SECRET}
TZ=${TIMEZONE}
EOF
    chown xormon:xormon "$ENVFILE"
    chmod 600 "$ENVFILE"

    # ensure the persisted data dir is owned by the app user
    chown -R xormon:xormon "$APPDIR/server-nest/files" 2>/dev/null || true

    rm -f /firstrun
fi

# start the application in the foreground as the xormon user.
# npm run start:runtime = node dist/verify.js && pm2-runtime production.config.js
exec runuser -u xormon -- bash -lc "cd '$APPDIR/server-nest' && exec npm run start:runtime"
