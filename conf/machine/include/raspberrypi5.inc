# Boot chain: Pi firmware -> U-Boot (as kernel_2712.img) -> /boot.scr on otaroot -> OSTree
RPI_USE_U_BOOT = "1"
ENABLE_UART = "1"

# meta-updater's sota_raspberrypi class targets RPi 2-4 with a FIT image;
# use Torizon's generic U-Boot distro boot flow instead.
SOTA_MACHINE:raspberrypi5 = "none"
OSTREE_BOOTLOADER:raspberrypi5 = "u-boot"
PREFERRED_PROVIDER_virtual/bootloader:raspberrypi5 = "u-boot"
PREFERRED_PROVIDER_u-boot-default-script:raspberrypi5 = "u-boot-distro-boot"

WKS_FILE:sota:raspberrypi5 = "torizon-am62xx-sota.wks"
IMAGE_FSTYPES:append:raspberrypi5 = " wic"
IMAGE_FSTYPES:remove:raspberrypi5 = "tar.bz2 ext3 wic.bz2"

# The boot partition only holds the firmware, its device trees and U-Boot:
# kernel and boot.scr live in the OSTree sysroot.
IMAGE_BOOT_FILES:append:raspberrypi5 = " ${BOOTFILES_DIR_NAME}/* ${@make_dtb_boot_files(d)} u-boot.bin;${SDIMG_KERNELIMAGE}"

UBOOT_BOOT_PARTITION_NUMBER:raspberrypi5 = "2"
OTAROOT_PARTITION_NUMBER:raspberrypi5 = "2"

# U-Boot replaces the kernel arguments added by the firmware: keep the ones
# Linux needs. Without 8250.nr_uarts=1 the Bluetooth UART does not probe.
OSTREE_KERNEL_ARGS:sota:raspberrypi5 = "console=tty1 console=ttyAMA10,115200 root=LABEL=otaroot rootfstype=ext4 \
    8250.nr_uarts=1 pci=pcie_bus_safe coherent_pool=1M reboot=w"

# U-Boot defines kernel_comp_addr_r, so uEnv.txt loads the kernel at loadaddr
# while booti starts it from kernel_addr_r: make them the same address.
# U-Boot sets fdtfile with a broadcom/ prefix, but OSTree installs the device
# trees without it. The device tree comes from OSTree like on other machines;
# U-Boot copies the firmware values (MAC address, CMA, dma-ranges) into it.
UENV_EXTRA_CONFIGS:raspberrypi5 = 'env set loadaddr ${kernel_addr_r}; setexpr fdtfile sub "^broadcom/" "" ${fdtfile}'

# Applied by U-Boot from overlays.txt; config.txt overlays only change the
# firmware device tree.
OSTREE_DEVICETREE_OVERLAY_BOOT:raspberrypi5 = "vc4-kms-v3d-pi5.dtbo"
