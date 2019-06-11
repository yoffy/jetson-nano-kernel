#!/bin/bash

set -eu

function usage() {
	ME=$(basename $0)
	echo "
usage: ${ME} device

Clone SD card to external storage.

device
	Destination device to be erased and cloned. (ex. /dev/sda)
"
}

function is_mounted() {
	if df | grep "^${DEV}" > /dev/null; then
		return 0
	else
		return 1
	fi
}

function atexit() {
	if [[ -n $DST ]]; then
		if is_mounted; then
			sudo umount "${DST}" && true
		fi
		rmdir "${DST}"
	fi
}

function erase() {
	echo "WARNING: ${DEV} to be erased!"
	echo "continue? [y/N]"
	read ANSWER
	case "${ANSWER}" in
		y | Y | yes)
			sudo parted -s "${DEV}" -- mklabel gpt mkpart primary 0% 100%
			sudo mkfs.ext4 "${DEV}"
		;;
		*)
			exit 1
		;;
	esac
}

if [[ $# -ne 1 ]] || [[ ! -e $1 ]]; then
	usage
	exit 1
fi

DEV=$1
SRC=/
DST=$(mktemp -d)
trap atexit EXIT ERR

if is_mounted; then
	echo "${DEV} is mounted."
	echo "Unmount ${DEV} before run this script."
	exit 1
fi

# install rsync
if ! type rsync >/dev/null 2>&1; then
	sudo apt install -y rsync
fi

# erase storage (can be commented out)
if ! erase; then
	exit 1
fi

sudo mount "${DEV}" "${DST}"
sudo rsync -axHAWX --numeric-ids --progress --exclude=/proc --exclude=/tmp "${SRC}" "${DST}"
