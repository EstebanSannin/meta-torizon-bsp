# Arduino App Lab: install App Lab app releases from Torizon Cloud as a
# subsystem update (hardware ID arduino-applab-<board>).

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " file://arduino-app-actions.sh"

DEPENDS:append = " jq-native"

ARDUINO_APP_TARGET ?= ""
ARDUINO_APP_TARGET:ventuno-q ?= "ventunoq"
ARDUINO_USER ?= "arduino"

do_install:append () {
    if ${@bb.utils.contains('MACHINE_FEATURES', 'arduino-applab', 'true', 'false', d)} && \
       [ -n "${ARDUINO_APP_TARGET}" ]; then
        sed -e 's#@ARDUINO_USER@#${ARDUINO_USER}#' -e 's#@ARDUINO_TARGET@#${ARDUINO_APP_TARGET}#' \
            ${UNPACKDIR}/arduino-app-actions.sh > ${UNPACKDIR}/arduino-app-actions.sh.out
        install -d ${D}${bindir}
        install -m 0744 ${UNPACKDIR}/arduino-app-actions.sh.out ${D}${bindir}/arduino-app-actions.sh

        jq '.["torizon-generic"] +=
             [{"partial_verifying": false,
               "ecu_hardware_id": "arduino-applab-${ARDUINO_APP_TARGET}",
               "full_client_dir": "/var/sota/storage/arduino-app",
               "ecu_private_key": "sec.private",
               "ecu_public_key": "sec.public",
               "firmware_path": "/var/sota/storage/arduino-app/release.ard",
               "target_name_path": "/var/sota/storage/arduino-app/target_name",
               "metadata_path": "/var/sota/storage/arduino-app/metadata",
               "action_handler_path": "${bindir}/arduino-app-actions.sh"}]' \
            ${D}${libdir}/sota/secondaries.json > ${UNPACKDIR}/secondaries.json.tmp
        install -m 0644 ${UNPACKDIR}/secondaries.json.tmp ${D}${libdir}/sota/secondaries.json
    fi
}

FILES:${PN}:append = " ${bindir}/arduino-app-actions.sh"
