Common Torizon OS for Qualcomm machines
=======

Supported machines, from [meta-qcom-arduino](https://github.com/qualcomm-linux/meta-qcom-arduino):
 * `ventuno-q` - Arduino VENTUNO Q (Qualcomm QCS8300 / Dragonwing IQ-8275)
 * `uno-q` - Arduino UNO Q (Qualcomm QRB2210 / QCM2290)

Boot flow: XBL -> UEFI -> systemd-boot -> UKI -> OSTree. On the VENTUNO Q the UEFI
firmware is Qualcomm's; on the UNO Q the Android bootloader (ABL) loads U-Boot from the
`boot_a`/`boot_b` partitions, and U-Boot provides UEFI. In both cases the OSTree
integration (BLS entries with boot counting, `qcomflash` image) comes from the
`sota_qcom` class of meta-updater, and no U-Boot environment or boot script is used.

Setup
======
1. Set up the default git user and e-mail:
```
$ git config --global user.email "you@example.com"
$ git config --global user.name "Your Name"
```
2. Install the repo utility to the development host:
```
$ mkdir ~/bin
$ PATH=~/bin:$PATH
$ curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
$ chmod a+x ~/bin/repo
```
3. Initialize and sync the Torizon repositories in an empty working directory:
```
$ mkdir ~/yocto-workdir && cd ~/yocto-workdir
$ repo init -u https://github.com/torizon/manifest.git -b wrynose-8.x.y -m torizon/qcom/integration.xml
$ repo sync
```
> [!IMPORTANT]
> Until an official release, only `integration.xml` (external layers pinned) and
> `next.xml` (all layers on branch HEAD) are available for Qualcomm machines.

Build
======
1. Start the build container in the work directory:
```
$ docker run --rm -it --name=crops -v ~/yocto-workdir:/workdir --workdir=/workdir torizon/crops:scarthgap-7.x.y /bin/bash
```
2. Set up the environment and build:
```
$$ git config --global user.email "you@example.com"
$$ git config --global user.name "Your Name"
$$ MACHINE=ventuno-q source setup-environment build-ventuno-q
$$ bitbake torizon-docker
```
The flashable package is
`build-ventuno-q/deploy/images/ventuno-q/torizon-docker-ventuno-q.qcomflash.tar.gz`.
For the UNO Q, use `MACHINE=uno-q` and `build-uno-q` instead.

Flash the Device
======
The board is flashed in Emergency Download (EDL) mode with
[qdl](https://github.com/linux-msm/qdl). Flashing erases the whole eMMC.

1. Unpack the package on the host connected to the board:
```
$ tar xzf torizon-docker-ventuno-q.qcomflash.tar.gz
$ cd torizon-docker-ventuno-q
```
2. Enter EDL mode:
    1. Disconnect all cables from the board (power, USB-C, serial).
    2. Bridge pin 1 (`GND`) and pin 2 (`FORCE_BOOT`) of the `JCTL` header with a jumper.
       See the [VENTUNO Q full pinout](https://docs.arduino.cc/resources/pinouts/ABX00181-full-pinout.pdf).
    3. Connect power, then connect the USB-C port to the host.

   The host must detect the board as `05c6:9008`:
```
$ lsusb -d 05c6:9008
```
3. Flash:
```
$ qdl -s emmc prog_firehose_ddr.elf rawprogram0.xml rawprogram1.xml patch0.xml patch1.xml
```

On the **UNO Q**, which is powered from its USB-C port:
1. Disconnect the USB-C cable.
2. Bridge `USB_BOOT` and the `GND` pin next to it on the `JCTL` header (the two pins
   farthest from the USB-C connector) with a jumper. See the
   [UNO Q full pinout](https://docs.arduino.cc/resources/pinouts/ABX00162-full-pinout.pdf).
3. Connect the USB-C port to the host; it must detect the board as `05c6:9008`.
4. Flash (the UNO Q package has a single `rawprogram`/`patch` pair):
```
$ qdl -s emmc prog_firehose_ddr.elf rawprogram0.xml patch0.xml
```
Flashing does not touch the eMMC boot partitions, where the UNO Q keeps its Wi-Fi and
Bluetooth MAC addresses.

Boot
======
1. Disconnect all cables, remove the `JCTL` jumper, connect Ethernet and HDMI, then power
   the board on.
2. The serial console is `ttyMSM0` at 115200 baud, on the `JCTL` header. The `JCTL` pins
   are 1.8 V logic only: use a 1.8 V USB-to-UART adapter. Disconnect it before a power
   cycle and reconnect it after power-on: if it stays connected, it can back-power the
   board, which then does not boot.
3. Log in as `torizon`; the default password is `torizon` and must be changed at first
   login.

The UNO Q has no Ethernet port: remove the jumper, power it from USB-C, log in on the
serial console (`ttyMSM0`, 115200 baud, `JCTL` header, 1.8 V) and set up Wi-Fi:
```
$ sudo nmcli dev wifi connect "<SSID>" --ask
```

Known limitations
======
 * On the VENTUNO Q the HDMI EDID is currently not read (`/sys/class/drm/card0-HDMI-A-1/edid`
   is empty), so the display falls back to 1024x768.
 * The boot firmware (XBL, UEFI) is not updated through Torizon OTA.
 * After a warm reboot the Ethernet interface occasionally receives no packets (no DHCP
   lease) although the link is up; `ip link set eth0 down && ip link set eth0 up`
   recovers it.
 * No permanent Ethernet MAC address is provided to Linux, so a random one is used. The
   DHCP address stays stable, as the client ID is derived from the machine ID.
 * meta-qcom CI applies extra patches to meta-lts-mixins for other SoCs (shikra, qcs615);
   they are not needed by the machines listed here and are not applied by the manifest.
 * On the UNO Q, U-Boot (in `boot_a`/`boot_b`) is not updated through Torizon OTA either.
 * On the UNO Q, the Android bootloader stops in fastboot after a few boots unless the
   boot slot is marked as successful. `qbootctl` (from meta-qcom) does it at every boot.
 * The UNO Q has no battery-backed RTC: until NTP synchronizes the clock after boot,
   TLS connections (and so Torizon Cloud) fail, and the first report after an update can
   take a few minutes.
 * On the UNO Q, `adsprpcd_audiopd.service` fails at boot: the QCM2290 device tree
   reserves no memory for the audio DSP process, and the board has no sound card.
   `systemd-networkd-wait-online.service` fails without a wired network.
