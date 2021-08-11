#!/bin/bash

set -eu

source download-kernel.sh

CONFIG_SIANO_PATCH=$(pwd)/config-siano.patch
SIANO_PATCH=$(pwd)/siano.patch
XHCI_RING_PATCH=$(pwd)/xhci-ring.patch

export LOCALVERSION="-tegra"
export ARCH=arm64

pushd workdir

# patch for PX-S1UD/PX-Q1UD
pushd "${KERNEL_DIR}"
patch -p1 -N < "${SIANO_PATCH}" && true
patch -p1 -N < "${XHCI_RING_PATCH}" && true
popd

echo "Configuring kernel"
rm -f "${TEGRA_KERNEL_OUT}/.config"
make -C ${KERNEL_DIR} O=${TEGRA_KERNEL_OUT} tegra_defconfig
patch -p1 -N ${TEGRA_KERNEL_OUT}/.config < "${CONFIG_SIANO_PATCH}"

echo "Making kernel"
make -C ${KERNEL_DIR} -j$(( $(nproc) + 1 )) O=${TEGRA_KERNEL_OUT} Image dtbs modules

echo "Install"
sudo cp "${TEGRA_KERNEL_OUT}"/arch/arm64/boot/Image /boot/
sudo cp -r "${TEGRA_KERNEL_OUT}"/arch/arm64/boot/dts/* /boot/
sudo make -C ${KERNEL_DIR} O=${TEGRA_KERNEL_OUT} modules_install

popd
