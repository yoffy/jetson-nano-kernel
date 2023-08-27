#!/bin/bash

set -eu

TEGRA_KERNEL_OUT=`pwd`/workdir/out
## https://developer.nvidia.com/embedded/jetson-linux-archive
## -> Driver package (BSP) Sources
PACK_NAME=public_sources.tbz2
PACK_URL="https://developer.download.nvidia.com/embedded/L4T/r32_Release_v7.4/Sources/T210/public_sources.tbz2"
#PACK_SIZE=$(LC_ALL=C wget --spider "${PACK_URL}" 2>&1 | grep '^Length: [0-9]\+' | cut -d' ' -f2)
PACK_SIZE=162093940
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
if ! CheckFileSize "${PACK_NAME}" ${PACK_SIZE}; then
	rm -rf "${PACK_NAME}" "${KERNEL_DIR}"
	echo "Downloading ${PACK_URL}"
	wget -O "${PACK_NAME}" "${PACK_URL}"
fi
if [[ ${PACK_NAME} -nt ${KERNEL_DIR} ]]; then
	echo "${PACK_NAME} newer than ${KERNEL_DIR}. Clean ${KERNEL_DIR} and ${TEGRA_KERNEL_OUT}."
	rm -rf "${KERNEL_DIR}" "${TEGRA_KERNEL_OUT}"
fi

# extract kernel source code
if [[ ! -d ${KERNEL_DIR} ]]; then
	echo "Extracting ${PACK_NAME}"
	tar -xf "${PACK_NAME}" Linux_for_Tegra/source/public/kernel_src.tbz2
	tar -xf Linux_for_Tegra/source/public/kernel_src.tbz2
	rm -rf Linux_for_Tegra
fi

touch "${KERNEL_DIR}"

popd
