# Jetson Nano Kernel Builder

## Includes

* Intel Dual Band Wireless-AC 9260 driver module (iwlwifi)
	* WiFi and Bluetooth
* SMB 2.1 driver module

## How to use

### Clone this repository to your fastest storage that mounted on Jetson Nano

`build-kernel.sh` of this repository downloads kernel source code and makes it under the cloned directory.

```
$ git clone https://github.com/yoffy/jetson-nano-kernel.git
```

### Build

Build and install to SD card:

```
$ cd jetson-nano-kernel
$ ./build-kernel.sh
$ ./install-kernel.sh
$ ./install-iwlwifi.sh
$ ./install-cifs
$ sudo reboot
```

### (optional) Clone SD card into USB storage

WARNING: `clone-storage.sh` erases the target device

```
$ ./clone-storage.sh /dev/sda
```

Edit exlinux.conf of SD card for booting from USB storage:

```
$ sudoedit /boot/extlinux/extlinux.conf
:
	APPEND ${cbootargs} rootfstype=ext4 root=/dev/sda rw rootwait
```

If failed to booting, revert `extlinux.conf` to `root=/dev/mmcblk0p1`.

### (optional) Mount SMB (cifs)

Add arguments `-o vers=2.1` to `mount` if occurs `error(95)` like below:

```sh
$ sudo mount -t cifs -o //network-volume /mnt/netvol
mount error(95): Operation not supported
Refer to the mount.cifs(8) manual page (e.g. man mount.cifs)
```

Fixed command:

```sh
$ sudo mount -t cifs -o vers=2.1 //network-volume /mnt/netvol
```
