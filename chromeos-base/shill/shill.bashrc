# Copyright (c) 2025 Fyde Innovations Limited and the openFyde Authors.
# Distributed under the license specified in the root directory of this project.

cros_pre_src_prepare_xpressreal_patches() {
  if [ $PV == "9999" ]; then
    return
  fi
  eapply  ${TEETHREE_BASHRC_FILESDIR}/select-service-for-cellular-device.patch
}
