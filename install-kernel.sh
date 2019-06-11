#!/bin/bash

set -eu

TEGRA_KERNEL_OUT=`pwd`/workdir/out

sudo mv -n /boot/Image /boot/Image.orig
sudo cp "${TEGRA_KERNEL_OUT}/arch/arm64/boot/Image" /boot/
sudo cp "${TEGRA_KERNEL_OUT}/arch/arm64/boot/dts/*" /boot/
#sudo mv -n /boot/extlinux/extlinux.conf /boot/extlinux/extlinux.conf.orig
#sudo cp extlinux.conf /boot/extlinux/
