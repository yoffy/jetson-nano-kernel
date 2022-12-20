#!/bin/bash

set -eu

BUILD_BUG_H_PATCH="${PWD}/build_bug.h.patch"

source download-kernel.sh

pushd workdir

# download wifi driver source code
if [[ ! -d backport-iwlwifi ]]; then
	git clone https://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/backport-iwlwifi.git
fi
pushd backport-iwlwifi
git fetch origin
git checkout origin/release/core52
# patch for L4T 32.7.3
git apply "${BUILD_BUG_H_PATCH}"
popd

# clean
make -C backport-iwlwifi clean
rm -rf backport-iwlwifi/.config

# configure
make -C backport-iwlwifi defconfig-iwlwifi-public

# compile
make -C backport-iwlwifi -j$(( $(nproc) + 1 ))

# install driver
sudo make -C backport-iwlwifi modules_install


# download firmwares
if [[ ! -d linux-firmware ]]; then
	git clone https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
else
	pushd linux-firmware
	git pull
	popd
fi

# install firmwares
sudo cp linux-firmware/iwlwifi-9260* /lib/firmware/

popd

./install-btusb.sh
