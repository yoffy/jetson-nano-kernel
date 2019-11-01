#!/bin/bash

set -eu

TEGRA_KERNEL_OUT=`pwd`/workdir/out
PACK_NAME=public_sources.tbz2
PACK_URL="https://developer.nvidia.com/embedded/dlc/r32-2-1_Release_v1.0/Nano-TX1/sources/${PACK_NAME}"
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
	echo "Downloading ${PACK_URL}"
	wget "${PACK_URL}"
fi

# extract kernel source code
if [[ ! -d ${KERNEL_DIR} ]]; then
	echo "Extracting ${PACK_NAME}"
	tar -xf "${PACK_NAME}" public_sources/kernel_src.tbz2
	tar -xf public_sources/kernel_src.tbz2
	rm -rf public_sources
fi

popd
