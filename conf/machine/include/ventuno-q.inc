# Torizon integration overlay for the Arduino VENTUNO Q (Qualcomm QCS8300 /
# Dragonwing IQ-8275). Auto-included for MACHINE=ventuno-q via the local.conf
# template, on top of the machine from meta-qcom-arduino.

require common-qcom.inc

# usb_2 (link to the MCU) cannot detect devices after boot until restarted
MACHINE_EXTRA_RRECOMMENDS:append = " ventuno-q-usb2-reset"

# The HDMI EDID of the monitor is not read (1024x768): default to 1080p60
MACHINE_EXTRA_RRECOMMENDS:append = " ventuno-q-edid"
OSTREE_KERNEL_ARGS:append = " drm.edid_firmware=HDMI-A-1:edid/1080p60.bin"

# Arduino App Lab support, from meta-arduino-applab
MACHINE_FEATURES:append = " arduino-applab"

# App Lab logs in as 'arduino' with UID 1000: give it UID/GID 1000 and move
# 'torizon' to 1001 (same groups and sudo; Torizon relies on the name). Later
# tables override earlier ones (useradd-staticids).
USERADD_UID_TABLES:append = "${@bb.utils.contains('MACHINE_FEATURES', 'arduino-applab', ' files/arduino-applab-static-passwd', '', d)}"
USERADD_GID_TABLES:append = "${@bb.utils.contains('MACHINE_FEATURES', 'arduino-applab', ' files/arduino-applab-static-group', '', d)}"
