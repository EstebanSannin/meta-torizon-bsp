FILESEXTRAPATHS:prepend:raspberrypi5 := "${THISDIR}/raspberrypi5:"

SRC_URI:append:raspberrypi5 = " \
    file://bootcommand.cfg \
    file://0001-libfdt-backport-the-overlay-fixes-from-U-Boot-v2026.04.patch \
    file://0002-rpi-copy-the-Bluetooth-address-through-the-bluetooth-alias.patch \
"
