#!/bin/sh

set -e -o pipefail

mount_file() {
    FILE=$1
    MOUNT_TARGET="/usr/palm/applications/com.webos.app.screensaver/qml/UserInterfaceLayer/Containers/$FILE"
    QML_PATH="/home/root/custom_screensaver/$FILE"

    if [[ ! -f "$MOUNT_TARGET" ]]; then
        echo "[-] Target file does not exist: $MOUNT_TARGET" >&2
        exit 1
    fi

    if ! findmnt "$MOUNT_TARGET"; then
        mount --bind "$QML_PATH" "$MOUNT_TARGET"
        echo "[+] Enabled succesfully for $FILE" >&2
    else
        echo "[~] Enabled already for $FILE" >&2
    fi
}

# Call the function for each file
mount_file "MainView.qml"
mount_file "Clock.qml"
mount_file "ScreenSaver.qml"
