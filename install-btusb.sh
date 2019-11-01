#!/bin/bash

set -eu

MAKEJ="make -j$(( $(nproc) + 1 ))"
BTUSB_PATCH=`pwd`/btusb.patch
INSTALL_DIR=/lib/modules/`uname -r`/kernel/drivers/bluetooth

source download-kernel.sh

pushd workdir/${KERNEL_DIR}

echo "Patch"
patch -p1 -N < "${BTUSB_PATCH}" && true

echo "Configuring kernel"
${MAKEJ} ARCH=arm64 O=${TEGRA_KERNEL_OUT} tegra_defconfig
${MAKEJ} ARCH=arm64 O=${TEGRA_KERNEL_OUT} prepare
${MAKEJ} ARCH=arm64 O=${TEGRA_KERNEL_OUT} scripts

# need to make twice (why?)
echo "Making module"
${MAKEJ} ARCH=arm64 O=${TEGRA_KERNEL_OUT} M=drivers/bluetooth
${MAKEJ} ARCH=arm64 O=${TEGRA_KERNEL_OUT} M=drivers/bluetooth

echo "Installing module"
sudo modprobe -r btusb
sudo cp ${TEGRA_KERNEL_OUT}/drivers/bluetooth/btusb.ko ${INSTALL_DIR}/

popd
