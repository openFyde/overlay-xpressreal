# Copyright 2024 The FydeOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit linux-info

AIC_TAG="4.0+git20250410.b99ca8b6-1"

DESCRIPTION="AIC8800 sdio WiFi kernel drivers and firmwares"
HOMEPAGE="https://github.com/radxa-pkg/aic8800"
SRC_URI="https://github.com/radxa-pkg/aic8800/archive/refs/tags/${AIC_TAG}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="arm64"

IUSE_FIRMWARE=(
  aic8800
  aic8800d80
  aic8800dc
)
IUSE="${IUSE_FIRMWARE[*]/#/linux_firmware_} kernel-6_12"

DEPEND="virtual/linux-sources"
RDEPEND=""

S="${WORKDIR}/aic8800-4.0-git20250410.b99ca8b6-1"
DRIVER_DIR="${S}/src/SDIO/driver_fw/driver/aic8800"
FIRMWARE_DIR="${S}/src/SDIO/driver_fw/fw"

# radxa's kernel-compat series for the SDIO driver (version-guarded upstream).
RADXA_PATCHES=(
  fix-sdio-fall-through
  fix-linux-6.1-build
  fix-linux-6.7-build
  fix-linux-6.5-build
  fix-linux-6.9-build
  fix-linux-6.12-build
  fix-linux-6.13-build
  fix-linux-6.14-build
  fix-linux-6.15-build
  fix-linux-6.16-build
)


pkg_setup() {
  if use kernel-6_12; then
    export KERNEL_DIR="/mnt/host/source/src/third_party/kernel/v6.12"
  else
    die "no supported kernel-* USE flag set for ${PN}"
  fi
  export KBUILD_OUTPUT="${ROOT}/usr/src/linux"
  # Not linux-info_pkg_setup: the CrOS eclass fork no-ops it unless
  # linux-mod is inherited, leaving KV_FULL unset.
  linux-info_get_any_version
}

src_prepare() {
  local p
  for p in "${RADXA_PATCHES[@]}"; do
    eapply "${S}/debian/patches/${p}.patch"
  done
  pushd "${DRIVER_DIR}" >/dev/null || die
  eapply "${FILESDIR}/${PV}-clang-fix-for-chromium-os.patch"
  popd >/dev/null || die
  default
}

src_compile() {
  # Same clang/LLVM toolchain the kernel is built with (cros-kernel.eclass);
  # LLVM=1 is rejected by the SDK's unprefixed-tool wrappers. The vendor
  # driver is not warning-clean, so keep CONFIG_WERROR off for it.
  emake -C "${KERNEL_DIR}" M="${DRIVER_DIR}" ARCH=arm64 \
    CROSS_COMPILE="${CHOST}-" \
    CC="${CHOST}-clang" LD="ld.lld" \
    NM="llvm-nm" AR="llvm-ar" \
    OBJCOPY="llvm-objcopy" STRIP="llvm-strip" \
    CONFIG_WERROR= \
    modules
}

src_install() {
  insinto "/lib/modules/${KV_FULL}/kernel/drivers/net/wireless/aic8800"
  doins "${DRIVER_DIR}"/aic8800_bsp/aic8800_bsp.ko \
    "${DRIVER_DIR}"/aic8800_fdrv/aic8800_fdrv.ko \
    "${DRIVER_DIR}"/aic8800_btlpm/aic8800_btlpm.ko

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

pkg_postinst() {
  # linux-mod's depmod path is broken under EAPI 7; run depmod ourselves.
  depmod -a -b "${ROOT:-/}" "${KV_FULL}"
}
