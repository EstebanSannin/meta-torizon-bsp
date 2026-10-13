# Torizon integration overlay for the Arduino VENTUNO Q (Qualcomm QCS8300 /
# Dragonwing IQ-8275). Auto-included for MACHINE=ventuno-q via the local.conf
# template, on top of the machine from meta-qcom-arduino.

require common-qcom.inc

# usb_2 (link to the MCU) cannot detect devices after boot until restarted
MACHINE_EXTRA_RRECOMMENDS:append = " ventuno-q-usb2-reset"

# The HDMI EDID of the monitor is not read (1024x768): default to 1080p60
MACHINE_EXTRA_RRECOMMENDS:append = " ventuno-q-edid"
OSTREE_KERNEL_ARGS:append = " drm.edid_firmware=HDMI-A-1:edid/1080p60.bin"

# Arduino App Lab support, from meta-arduino-applab (the Torizon integration
# is in meta-torizon)
MACHINE_FEATURES:append = " arduino-applab"
# App Lab's name for the board
ARDUINO_APP_TARGET = "ventunoq"
# App Lab's USB setup needs adbd 35 (shell v2), not selected by default
PREFERRED_VERSION_android-tools ?= "${@bb.utils.contains('MACHINE_FEATURES', 'arduino-applab', '35.0.2', '', d)}"
