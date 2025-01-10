
teethree_stack_bashrc() {
  local cfg

  cfgd="/mnt/host/source/src/overlays/overlay-teethree/${CATEGORY}/${PN}"
  for cfg in ${PN} ${P} ${PF} ; do
    cfg="${cfgd}/${cfg}.bashrc"
    [[ -f ${cfg} ]] && . "${cfg}"
  done

  export TEETHREE_BASHRC_FILESDIR="${cfgd}/files"
}

teethree_stack_bashrc
