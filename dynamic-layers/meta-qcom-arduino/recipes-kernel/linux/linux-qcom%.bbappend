FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append:ventuno-q = " file://0001-arm64-dts-qcom-monaco-arduino-monza-enable-the-USB-link-to-the-MCU.patch \
    file://0002-misc-fastrpc-give-back-a-closed-user-s-contexts-and-mappings.patch \
    file://0003-net-stmmac-qcom-ethqos-configure-the-SerDes-for-the-interface-mode.patch \
    file://ventuno-q-edid.cfg \
"
