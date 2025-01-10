cros_post_src_prepare_teethree_patch() {
  if [[ ${PV} == "9999" ]]; then
    return
  fi
  eapply ${TEETHREE_BASHRC_FILESDIR}/*.patch
}
