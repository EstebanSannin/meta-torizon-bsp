SUMMARY = "Torizon OS integration of Arduino App Lab"
DESCRIPTION = "App Lab logs in as 'arduino' and expects UID 1000. On Torizon OS \
'arduino' gets UID 1000 with the same groups and sudo as 'torizon', which moves \
to UID 1001 (see the static ID tables in ventuno-q.inc)."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://arduino-applab-torizon.tmpfiles"

S = "${UNPACKDIR}"

inherit useradd allarch

USERADD_DEPENDS = "torizon-users"
USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM:${PN} = "-g 1000 arduino; -r arduino-router; -r docker"
# password 'arduino' (openssl passwd -6), to be changed at first use as on
# Arduino's images
USERADD_PARAM:${PN} = "-u 1000 -g arduino \
    -G adm,sudo,users,plugdev,audio,video,gpio,i2cdev,spidev,dialout,input,pwm,docker,arduino-router \
    -M -d /var/rootdirs/home/arduino -s /bin/bash -p '\$6\$arduinoapplab\$peSASu9kXM.xFypd9VD8oouplMV9vkoOIXi5uPIDnlaDkMQQEmQ/HmCW7plNznihI3CoFnefUMc0f8Bs8./4l/' arduino"

do_install() {
    install -D -m 0644 ${S}/arduino-applab-torizon.tmpfiles ${D}${nonarch_libdir}/tmpfiles.d/arduino-applab-torizon.conf
}

FILES:${PN} += "${nonarch_libdir}/tmpfiles.d"

pkg_postinst_ontarget:${PN} () {
    if [ ! -e /etc/.arduino_passwd_expired ]; then
        passwd -e arduino
        touch /etc/.arduino_passwd_expired
    fi
}

RDEPENDS:${PN} += "torizon-users ${VIRTUAL-RUNTIME_container_engine}"
