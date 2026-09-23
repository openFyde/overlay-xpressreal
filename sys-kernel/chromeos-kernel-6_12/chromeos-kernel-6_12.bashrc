cros_post_src_prepare_add_teethree_patches() {
  if [[ ${PV} == "9999" ]]; then
    return
  fi
  eapply ${TEETHREE_BASHRC_FILESDIR}/*.patch
}
