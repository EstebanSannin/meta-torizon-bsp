FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append:ventuno-q = " file://0001-arm64-dts-qcom-monaco-arduino-monza-power-the-wlan-bt-module.patch \
    file://0002-arm64-dts-qcom-monaco-arduino-monza-enable-the-USB-link-to-the-MCU.patch \
    file://0003-misc-fastrpc-drop-leftover-invoke-contexts-on-release.patch \
    file://0004-net-stmmac-qcom-ethqos-configure-the-SerDes-for-the-interface-mode.patch \
    file://ventuno-q-edid.cfg \
"
