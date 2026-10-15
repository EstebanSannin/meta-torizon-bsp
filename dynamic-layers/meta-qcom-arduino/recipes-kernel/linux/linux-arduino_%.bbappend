# EXPERIMENTAL: Arduino's kernel tree (arduino/linux-qcom qcom-v7.2.8-arduino)
# for the VENTUNO Q, to compare with linux-qcom 6.18. meta-qcom-arduino builds
# this recipe for the UNO Q only; extend it to ventuno-q.

# torizon.cfg from recipes-kernel/linux/files. Not via linux-torizon.inc: its
# kernel_do_deploy append fails on a detached checkout (nobranch=1, git
# symbolic-ref exits 1).
FILESEXTRAPATHS:prepend:ventuno-q := "${THISDIR}/linux-arduino:${THISDIR}/files:${THISDIR}/../../../../recipes-kernel/linux/files:"

COMPATIBLE_MACHINE:ventuno-q = "ventuno-q"

LINUX_VERSION:ventuno-q = "7.2.8"
# qcom-v7.2.8-arduino, 2026-10-14
SRCREV:ventuno-q = "b5aaba71a68946fd4a8b57c649f6ebd5beb6180e"

# Already in this tree, so not carried: the QCA2066 power sequencer (replaces
# the Wi-Fi/BT GPIO hogs), the qcom-ethqos SerDes series from v7.1 and the
# fastrpc_user refcount the fastrpc fix builds on.
SRC_URI:append:ventuno-q = " \
    file://0001-arm64-dts-qcom-monaco-arduino-monza-enable-the-USB-link-to-the-MCU.patch \
    file://0002-misc-fastrpc-drop-leftover-invoke-contexts-on-release.patch \
    file://configs/ventuno-q.cfg \
    file://qcom-bsp-additions.cfg \
    file://torizon.cfg \
    file://ventuno-q-edid.cfg \
    file://linux-qcom-parity.cfg \
"

# The DTB is built with -@ (the tree composes it with overlays), and Qualcomm's
# UEFI crashes in its DT fixup on the UKI's DTB when /__symbols__ is present
# (data abort in DXE after systemd-stub installs it, ~30% of cold boots). No
# overlay is applied on this boot path: drop the node.
DEPENDS:append:ventuno-q = " dtc-native"
do_compile:append:ventuno-q() {
    dtb=${B}/arch/${ARCH}/boot/dts/qcom/monaco-arduino-monza.dtb
    if fdtget -l $dtb /__symbols__ >/dev/null 2>&1; then
        fdtput -r $dtb /__symbols__
    fi
}
