#!/bin/bash

set -eu

source download-kernel.sh

pushd workdir

# copy usb firmware
USB_FIRMWARE="tegra21x_xusb_firmware"
cp "/lib/firmware/${USB_FIRMWARE}" ${KERNEL_DIR}/firmware/

echo "Configuring kernel"
rm -f "${TEGRA_KERNEL_OUT}/.config"
make -C ${KERNEL_DIR} ARCH=arm64 O=${TEGRA_KERNEL_OUT} tegra_defconfig
bash ${KERNEL_DIR}/scripts/config \
	--file "${TEGRA_KERNEL_OUT}/.config" \
	--set-str LOCALVERSION "-tegra" \
	--set-str CONFIG_EXTRA_FIRMWARE "${USB_FIRMWARE}" \
	--set-str CONFIG_EXTRA_FIRMWARE_DIR "firmware"

echo "Making kernel"
make -C ${KERNEL_DIR} -j$(( $(nproc) + 1 )) ARCH=arm64 O=${TEGRA_KERNEL_OUT}

popd
