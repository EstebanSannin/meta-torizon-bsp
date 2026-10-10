# Arduino's U-Boot for the UNO Q carries an SMBIOS node in its device tree
# (system/baseboard/chassis: Arduino, Imola), so Linux reports the DMI
# product name "Imola". Arduino's tools rely on it: remoteocd only flashes the
# MCU locally when product_name is "imola", and the arduino-router generator
# picks the board drop-in from it. The kernel DTB that u-boot-arduino embeds
# has no such node, so U-Boot falls back to the model ("Arduino UnoQ").
# Add the same node to a copy of the DTB and repackage boot.img with it.

uboot_compile_config:append:uno-q() {
    cd ${B}/${builddir}
    cp ${DEPLOY_DIR_IMAGE}/${type}.dtb smbios-${type}.dtb
    fdtput -c smbios-${type}.dtb /smbios /smbios/smbios \
        /smbios/smbios/system /smbios/smbios/baseboard /smbios/smbios/chassis
    fdtput -t s smbios-${type}.dtb /smbios compatible u-boot,sysinfo-smbios
    for n in system baseboard chassis; do
        fdtput -t s smbios-${type}.dtb /smbios/smbios/$n manufacturer Arduino
        fdtput -t s smbios-${type}.dtb /smbios/smbios/$n product Imola
        fdtput -t s smbios-${type}.dtb /smbios/smbios/$n version 1.0
    done
    cat u-boot-nodtb.bin.gz smbios-${type}.dtb > u-boot-nodtb.bin.gz-${type}
    ${STAGING_BINDIR_NATIVE}/skales/mkbootimg --base 0x80000000 --pagesize 4096 --kernel u-boot-nodtb.bin.gz-${type} --cmdline "root=/dev/notreal" --ramdisk empty-file --output u-boot-${type}.bin
}
