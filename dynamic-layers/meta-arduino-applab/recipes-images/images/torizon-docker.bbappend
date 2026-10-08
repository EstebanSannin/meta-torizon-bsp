# Arduino App Lab, on machines that declare it (e.g. the Arduino VENTUNO Q)
IMAGE_INSTALL:append = "${@bb.utils.contains('MACHINE_FEATURES', 'arduino-applab', ' packagegroup-arduino-applab', '', d)}"

# Run after image-buildinfo and nss_altfiles_set_users_groups (torizon-base.inc)
IMAGE_PREPROCESS_COMMAND:append = "${@bb.utils.contains('MACHINE_FEATURES', 'arduino-applab', ' arduino_applab_build_id arduino_applab_etc_users', '', d)}"

# App Lab compares BUILD_ID (YYYYMMDD-NNN) with Arduino's latest OS image and
# reports the board as outdated without it.
arduino_applab_build_id () {
    echo "BUILD_ID=$(echo ${DATETIME} | cut -c1-8)-$(echo ${DATETIME} | cut -c9-12)" >> ${IMAGE_ROOTFS}${sysconfdir}/buildinfo
}
arduino_applab_build_id[vardepsexclude] += "DATETIME"

# With nss-altfiles only the "torizon" entries stay in /etc. 'arduino' is
# needed there too: passwd/chpasswd only edit /etc, and arduino-app-cli (static
# Go) resolves groups from /etc/group only, including the GPU/NPU groups apps
# get, and Arduino's name for the GPIO group.
arduino_applab_etc_users () {
    for f in passwd shadow; do
        grep -q '^arduino:' ${IMAGE_ROOTFS}${sysconfdir}/$f || \
            grep '^arduino:' ${IMAGE_ROOTFS}${libdir}/$f >> ${IMAGE_ROOTFS}${sysconfdir}/$f
    done
    for g in arduino arduino-router render fastrpc dmaheap; do
        grep -q "^$g:" ${IMAGE_ROOTFS}${sysconfdir}/group || \
            grep "^$g:" ${IMAGE_ROOTFS}${libdir}/group >> ${IMAGE_ROOTFS}${sysconfdir}/group || true
    done
    gpio_gid=$(grep '^gpio:' ${IMAGE_ROOTFS}${libdir}/group | cut -d: -f3)
    grep -q '^gpiod:' ${IMAGE_ROOTFS}${sysconfdir}/group || \
        echo "gpiod:x:${gpio_gid}:" >> ${IMAGE_ROOTFS}${sysconfdir}/group
}
