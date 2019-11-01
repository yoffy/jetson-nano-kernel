# Jetson Nano Kernel Builder

## Includes

* USB 3 driver in kernel
* Intel Dual Band Wireless-AC 9260 driver module (iwlwifi)
	* WiFi and Bluetooth

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
$ sudo reboot
```

### (option) Clone SD card into USB storage

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
