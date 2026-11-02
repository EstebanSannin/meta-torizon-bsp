FILESEXTRAPATHS:prepend:raspberrypi5 := "${THISDIR}/libubootenv/raspberrypi5:"

SRC_URI:append:raspberrypi5 = " file://fw_env.config"

PACKAGE_ARCH:raspberrypi5 = "${MACHINE_ARCH}"

do_install:append:raspberrypi5() {
    install -d ${D}${sysconfdir}
    install -m 0644 ${UNPACKDIR}/fw_env.config ${D}${sysconfdir}/
}
