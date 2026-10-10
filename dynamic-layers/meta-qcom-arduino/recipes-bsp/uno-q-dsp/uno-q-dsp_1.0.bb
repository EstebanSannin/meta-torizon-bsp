SUMMARY = "Arduino UNO Q: fastrpc configuration for the ADSP"
DESCRIPTION = "TEMPORARY, to review: adds the UNO Q to the fastrpc machine \
configuration (RB1 DSP binaries) and keeps adsprpcd_audiopd from failing at \
boot on a board without a sound card."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
    file://arduino-unoq.yaml \
    file://10-require-sound-card.conf \
"

S = "${UNPACKDIR}"

COMPATIBLE_MACHINE = "uno-q"
PACKAGE_ARCH = "${MACHINE_ARCH}"

do_install() {
    install -Dm 0644 ${S}/arduino-unoq.yaml ${D}${datadir}/qcom/conf.d/arduino-unoq.yaml
    install -Dm 0644 ${S}/10-require-sound-card.conf \
        ${D}${systemd_system_unitdir}/adsprpcd_audiopd.service.d/10-require-sound-card.conf
}

FILES:${PN} = " \
    ${datadir}/qcom/conf.d \
    ${systemd_system_unitdir}/adsprpcd_audiopd.service.d \
"
