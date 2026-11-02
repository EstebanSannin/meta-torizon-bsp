# Use the Torizon static groups (i2cdev, spidev) instead of i2c and spi
GROUPADD_PARAM:${PN} = "--system gpio"

do_install:append() {
    sed -i -e 's/GROUP="i2c"/GROUP="i2cdev"/g' -e 's/GROUP="spi"/GROUP="spidev"/g' \
        ${D}${sysconfdir}/udev/rules.d/99-com.rules
}
