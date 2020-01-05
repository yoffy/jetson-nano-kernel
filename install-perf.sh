#!/bin/bash

# Install perf command to $HOME/bin/

set -eu

# install libraries
sudo apt install -y libelf-dev systemtap-sdt-dev libaudit-dev libssl-dev libslang2-dev libperl-dev liblzma-dev libunwind-dev libdw-dev binutils-dev libiberty-dev

source download-kernel.sh

PERF_OUT=`pwd`/workdir/perf_out
mkdir -p "${PERF_OUT}"

pushd workdir

make -C ${KERNEL_DIR}/tools/perf ARCH=arm64 O=${PERF_OUT}
make -C ${KERNEL_DIR}/tools/perf ARCH=arm64 O=${PERF_OUT} install

popd
