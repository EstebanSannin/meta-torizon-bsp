Common Torizon OS for Raspberry Pi machines
=======

Supported machines:
 * `raspberrypi5` - Raspberry Pi 5, from
   [meta-raspberrypi](https://git.yoctoproject.org/meta-raspberrypi)

Boot flow: EEPROM bootloader -> U-Boot -> `boot.scr` -> OSTree. U-Boot is installed as
`kernel_2712.img` on the boot partition. As on other Torizon machines, U-Boot loads the
kernel, device tree and overlays from the OSTree deployment, so they are updated and rolled
back together; U-Boot copies the values set by the firmware (MAC address, memory) into the
device tree. Device tree overlays are listed in `overlays.txt` (`vc4-kms-v3d-pi5.dtbo` by
default): `dtoverlay` lines in `config.txt` only change the firmware device tree.

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
$ repo init -u https://github.com/torizon/manifest.git -b wrynose-8.x.y -m torizon/rpi/integration.xml
$ repo sync
```
> [!IMPORTANT]
> Until an official release, only `integration.xml` (external layers pinned) and
> `next.xml` (all layers on branch HEAD) are available for Raspberry Pi machines.

Build
======
1. Start the build container in the work directory:
```
$ docker run --rm -it --name=crops -v ~/yocto-workdir:/workdir --workdir=/workdir torizon/crops:wrynose-8.x.y /bin/bash
```
2. Set up the environment and build:
```
$$ git config --global user.email "you@example.com"
$$ git config --global user.name "Your Name"
$$ MACHINE=raspberrypi5 source setup-environment build-raspberrypi5
$$ bitbake torizon-docker
```
The setup asks to accept the `synaptics-killswitch` license of the Wi-Fi/Bluetooth
firmware (see meta-raspberrypi `docs/ipcompliance.md`); set `EULA=1` to accept it without
the prompt. Without it, the image is built without Wi-Fi and Bluetooth.

The image is `build-raspberrypi5/deploy/images/raspberrypi5/torizon-docker-raspberrypi5.wic`.

Flash the Device
======
Write the image to a microSD card (this erases the card):
```
$ sudo dd if=torizon-docker-raspberrypi5.wic of=/dev/sdX bs=4M conv=fsync status=progress
```

Boot
======
1. The EEPROM bootloader must be recent (tested with 2026-09-25): with older releases
   (e.g. 2024-02) the firmware mailbox does not work under Torizon (no clocks, RTC or
   display). Update it with Raspberry Pi Imager (Misc utility images -> Bootloader).
2. Insert the card, connect Ethernet and HDMI, then power the board on.
3. The serial console is `ttyAMA10` at 115200 baud, on the 3-pin UART connector between
   the HDMI ports.
4. Log in as `torizon`; the default password is `torizon` and must be changed at first
   login.
