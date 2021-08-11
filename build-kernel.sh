#!/bin/bash

set -eu

source download-kernel.sh

export LOCALVERSION="-tegra"
export ARCH=arm64

pushd workdir

echo "Configuring kernel"
rm -f "${TEGRA_KERNEL_OUT}/.config"
make -C ${KERNEL_DIR} O=${TEGRA_KERNEL_OUT} tegra_defconfig

echo "Making kernel"
make -C ${KERNEL_DIR} -j$(( $(nproc) + 1 )) O=${TEGRA_KERNEL_OUT} Image dtbs modules

popd
