#!/bin/bash

set -eu

source download-kernel.sh

pushd workdir

# download wifi driver source code
if [[ ! -d backport-iwlwifi ]]; then
	git clone https://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/backport-iwlwifi.git
fi
pushd backport-iwlwifi
git checkout release/core46
popd

# configure
make -C backport-iwlwifi defconfig-iwlwifi-public

# compile
make -C backport-iwlwifi -j$(( $(nproc) + 1 ))

# install driver
sudo make -C backport-iwlwifi modules_install


# download firmwares
if [[ ! -d linux-firmware ]]; then
	git clone git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
fi

# install firmwares
sudo cp linux-firmware/iwlwifi-9260* /lib/firmware/

popd

./install-btusb.sh
