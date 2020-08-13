#!/bin/bash

set -eu

TEGRA_KERNEL_OUT=`pwd`/workdir/out
PACK_NAME=public_sources.tbz2
PACK_URL="https://developer.nvidia.com/embedded/L4T/r32_Release_v4.3/Sources/T210/${PACK_NAME}"
KERNEL_DIR=kernel/kernel-4.9

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
	rm -rf "${PACK_NAME}" "${KERNEL_DIR}"
	echo "Downloading ${PACK_URL}"
	wget "${PACK_URL}"
fi

# extract kernel source code
if [[ ! -d ${KERNEL_DIR} ]]; then
	echo "Extracting ${PACK_NAME}"
	tar -xf "${PACK_NAME}" Linux_for_Tegra/source/public/kernel_src.tbz2
	tar -xf Linux_for_Tegra/source/public/kernel_src.tbz2
	rm -rf Linux_for_Tegra
fi

popd
