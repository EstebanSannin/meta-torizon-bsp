# Torizon integration overlay for the Arduino VENTUNO Q (Qualcomm QCS8300 /
# Dragonwing IQ-8275). Auto-included for MACHINE=ventuno-q via the local.conf
# template, on top of the machine from meta-qcom-arduino.

require common-qcom.inc

# meta-qcom master defaults to linux-qcom-next: build linux-qcom, which the
# kernel patches and meta-qcom-arduino's Wi-Fi/Bluetooth support target
PREFERRED_PROVIDER_virtual/kernel:ventuno-q = "linux-qcom"

# usb_2 (link to the MCU) cannot detect devices after boot until restarted
MACHINE_EXTRA_RRECOMMENDS:append = " ventuno-q-usb2-reset"

# The HDMI EDID of the monitor is not read (1024x768): default to 1080p60
MACHINE_EXTRA_RRECOMMENDS:append = " ventuno-q-edid"
OSTREE_KERNEL_ARGS:append = " drm.edid_firmware=HDMI-A-1:edid/1080p60.bin"
