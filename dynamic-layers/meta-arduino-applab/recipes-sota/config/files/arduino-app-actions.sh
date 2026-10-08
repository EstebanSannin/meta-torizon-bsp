#!/bin/sh
# Torizon subsystem update action handler: install an Arduino App Lab app
# release (.ard, built with 'arduino-app-cli app build'), start it and make it
# the default app (started at boot). Called by aktualizr with the action as
# first argument; the downloaded package is in $SECONDARY_FIRMWARE_PATH.

ARDUINO_USER="@ARDUINO_USER@"
TARGET="@ARDUINO_TARGET@"
WORK_DIR="/var/lib/arduino-app-cli/torizon-update"

log() {
    logger -t arduino-app-update -- "$*"
}

# Report a status to aktualizr (stdout, parsed when the exit code is 0)
reply() {
    msg=$(printf '%s' "$2" | tr -d '"' | tr -d '\\' | tr '\n' ' ')
    log "$1: $msg"
    printf '{"status": "%s", "message": "%s"}\n' "$1" "$msg"
}

# Run arduino-app-cli as the App Lab user, the owner of its data
app_cli() {
    su -s /bin/sh "$ARDUINO_USER" -c 'TMPDIR=/tmp arduino-app-cli "$@"' -- arduino-app-cli "$@"
}

do_install() {
    pkg="$SECONDARY_FIRMWARE_PATH"
    if [ ! -r "$pkg" ]; then
        reply failed "package not found"
        return
    fi

    # A release archive holds one directory, named after the release, with a
    # release.yaml stating the board it was built for
    name=$(tar -tzf "$pkg" 2>/dev/null | head -n 1 | cut -d / -f 1)
    if [ -z "$name" ]; then
        reply failed "not an App Lab release archive"
        return
    fi
    target=$(tar -xzOf "$pkg" "$name/release.yaml" 2>/dev/null | sed -n 's/^target: *//p')
    if [ "$target" != "$TARGET" ]; then
        reply failed "release $name is for '$target', this board is '$TARGET'"
        return
    fi

    # arduino-app-cli runs as the App Lab user: hand it a readable copy
    mkdir -p "$WORK_DIR"
    cp "$pkg" "$WORK_DIR/$name.ard"
    chown -R "$ARDUINO_USER" "$WORK_DIR"
    if ! out=$(app_cli app install "$WORK_DIR/$name.ard" 2>&1); then
        rm -f "$WORK_DIR/$name.ard"
        reply failed "install of $name failed: $(printf '%s' "$out" | tail -n 3)"
        return
    fi
    rm -f "$WORK_DIR/$name.ard"

    # One app runs at a time: stop whatever runs, start the new release
    app_cli app ps 2>/dev/null | awk 'NR > 1 && $2 == "running" { print $1 }' |
        while read -r running; do
            app_cli app stop "$running" >/dev/null 2>&1
        done
    if ! out=$(app_cli app start "release:$name" 2>&1); then
        reply failed "start of $name failed: $(printf '%s' "$out" | tail -n 3)"
        return
    fi
    app_cli properties set default "release:$name" >/dev/null 2>&1

    if app_cli app ps 2>/dev/null | grep -q "^release:$name  *running"; then
        reply ok "$name installed and running"
    else
        reply failed "$name installed but not running"
    fi
}

case "$1" in
    install)
        do_install
        exit 0
        ;;
    *)
        # get-firmware-info, complete-install: aktualizr's default processing
        # (it reports the last installed package)
        exit 64
        ;;
esac
