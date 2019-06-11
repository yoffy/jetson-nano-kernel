#!/bin/bash

set -eu

TEGRA_KERNEL_OUT=`pwd`/workdir/out

mkdir -p workdir
pushd workdir

# download wifi driver source code
if [[ ! -d backport-iwlwifi ]]; then
	git clone https://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/backport-iwlwifi.git
fi

# configure
make -C backport-iwlwifi KLIB_BUILD=${TEGRA_KERNEL_OUT} defconfig-iwlwifi-public
sed -i 's/CPTCFG_IWLMVM_VENDOR_CMDS=y/# CPTCFG_IWLMVM_VENDOR_CMDS is not set/' backport-iwlwifi/.config

# compile
make -C backport-iwlwifi -j$(( $(nproc) + 1 ))

# install
sudo make -C backport-iwlwifi modules_install
