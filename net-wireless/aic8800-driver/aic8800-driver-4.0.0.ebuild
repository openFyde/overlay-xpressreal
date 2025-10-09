# Copyright (c) 2018 The Fyde OS Authors. All rights reserved.
# Distributed under the terms of the BSD

EAPI="7"

inherit gcc-linux-mod

DESCRIPTION="AIC8000 sdio WiFi kernel drivers and firmwares"
HOMEPAGE="https://github.com/radxa-pkg/aic8800"
SRC_URI="https://github.com/radxa-pkg/aic8800/archive/refs/tags/4.0+git20250410.b99ca8b6-1.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm64"

IUSE_FIRMWARE=(
  aic8800
  aic8800d80
  aic8800dc
)

IUSE="${IUSE_FIRMWARE[*]/#/linux_firmware_}"

RDEPEND=""

DEPEND="${RDEPEND}"

MODULE_NAMES="
   aic8800_fdrv(net/wireless::aic8800_fdrv)
   aic8800_btlpm(net/wireless::aic8800_btlpm)
   aic8800_bsp(net/wireless::aic8800_bsp)"

MODULE_CONFIGS="CONFIG_AIC_WLAN_SUPPORT"
S="${WORKDIR}/aic8800-4.0-git20250410.b99ca8b6-1/src/SDIO/driver_fw/driver/aic8800"

FIRMWARE_DIR="${WORKDIR}/aic8800-4.0-git20250410.b99ca8b6-1/src/SDIO/driver_fw/fw"

src_install() {
  gcc-linux-mod_src_install
  insinto /lib/firmware/aic8800
  if use linux_firmware_aic8800; then
    doins ${FIRMWARE_DIR}/aic8800/*
  fi
  if use linux_firmware_aic8800d80; then
    doins ${FIRMWARE_DIR}/aic8800D80/*
  fi
  if use linux_firmware_aic8800dc; then
    doins ${FIRMWARE_DIR}/aic8800DC/*
  fi
  insinto /etc/init
  doins ${FILESDIR}/init/load-aic_wifi-modules.conf
  insinto /etc/modprobe.d
  doins ${FILESDIR}/modprobe.d/aic_device.conf
}

# there is a bug in linux-mod_pkg_preinst() that stop depmod from generating
pkg_preinst() {
	debug-print-function ${FUNCNAME} $*
	[ -n "${MODULES_OPTIONAL_USE}" ] && use !${MODULES_OPTIONAL_USE} && return

	[ -d "${D}/lib/modules" ] && UPDATE_DEPMOD=true || UPDATE_DEPMOD=false
	[ -d "${D}/lib/modules" ] && UPDATE_MODULEDB=true || UPDATE_MODULEDB=false
}

PATCHES=(
  "${FILESDIR}/${PV}-fix-for-chromium-os.patch"
)
