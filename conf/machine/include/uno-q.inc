# Torizon integration overlay for the Arduino UNO Q (Qualcomm QRB2210 /
# QCM2290). Auto-included for MACHINE=uno-q via the local.conf template, on
# top of the machine from meta-qcom-arduino.
#
# Boot flow: XBL -> UEFI + ABL (A/B slots) -> U-Boot (boot_a/boot_b) ->
# U-Boot EFI -> systemd-boot -> UKI. U-Boot only provides EFI here: the OSTree
# integration is the same as on the other qcom machines (sota_qcom).

require common-qcom.inc

# TEMPORARY, to review: fastrpc config for the UNO Q, no failing audiopd
MACHINE_EXTRA_RRECOMMENDS:append = " uno-q-dsp"

# Arduino App Lab support, from meta-arduino-applab
MACHINE_FEATURES:append = " arduino-applab"

# App Lab logs in as 'arduino' with UID 1000: give it UID/GID 1000 and move
# 'torizon' to 1001 (same groups and sudo; Torizon relies on the name). Later
# tables override earlier ones (useradd-staticids).
USERADD_UID_TABLES:append = "${@bb.utils.contains('MACHINE_FEATURES', 'arduino-applab', ' files/arduino-applab-static-passwd', '', d)}"
USERADD_GID_TABLES:append = "${@bb.utils.contains('MACHINE_FEATURES', 'arduino-applab', ' files/arduino-applab-static-group', '', d)}"
