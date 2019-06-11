#!/bin/bash

set -eu

TEGRA_KERNEL_OUT=`pwd`/workdir/out
PACK_NAME=l4t-sources-32-1-jetson-nano
PACK_URL="https://developer.nvidia.com/embedded/dlc/${PACK_NAME}"
WIFI_PATCH=`pwd`/0001-PCI-tegra-Fix-speed-change-code.patch

# @param $1 File path.
# @param $2 File size to required.
function CheckFileSize() {
	if [[ ! -f $1 ]]; then
		return 1
	fi
	LOCAL_SIZE=$(stat -c %s "$1")
	[[ LOCAL_SIZE -eq $2 ]]
}

mkdir -p workdir
pushd workdir
mkdir -p "${TEGRA_KERNEL_OUT}"

# download kernel source code
PACK_SIZE=$(wget --spider "${PACK_URL}" 2>&1 | grep '^Length: [0-9]\+' | cut -d' ' -f2)
if ! CheckFileSize "${PACK_NAME}" ${PACK_SIZE}; then
	echo "Downloading ${PACK_URL}"
	wget "${PACK_URL}"
fi

# extract kernel source code
if [[ ! -d kernel/kernel-4.9 ]]; then
	echo "Extracting ${PACK_NAME}"
	tar -xf "${PACK_NAME}" public_sources/kernel_src.tbz2
	tar -xf public_sources/kernel_src.tbz2
	rm -rf public_sources
fi

# patch kernel for iwlwifi-9620
pushd kernel/kernel-4.9
patch -p1 -N < "${WIFI_PATCH}" && true
popd

# copy usb firmware
USB_FIRMWARE="tegra21x_xusb_firmware"
cp "/lib/firmware/${USB_FIRMWARE}" kernel/kernel-4.9/firmware/

echo "Configuring kernel"
make -C kernel/kernel-4.9 ARCH=arm64 O=${TEGRA_KERNEL_OUT} tegra_defconfig
bash kernel/kernel-4.9/scripts/config \
	--file "${TEGRA_KERNEL_OUT}/.config" \
	--set-str LOCALVERSION "-tegra" \
	--set-str CONFIG_EXTRA_FIRMWARE "${USB_FIRMWARE}" \
	--set-str CONFIG_EXTRA_FIRMWARE_DIR "firmware"

echo "Making kernel"
make -C kernel/kernel-4.9 -j$(( $(nproc) + 1 )) ARCH=arm64 O=${TEGRA_KERNEL_OUT}
