# Copyright (c) 2018 The Fyde OS Authors. All rights reserved.
# Distributed under the terms of the BSD

EAPI="7"

inherit appid
DESCRIPTION="Creates an app id for this build and update the lsb-release file"
HOMEPAGE="http://fydeos.com"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND=""

DEPEND="${RDEPEND}"

S=${WORKDIR}

src_install() {
  doappid "{2C9A8C6F-ACC8-4655-BF40-4623F93B31BD}" "CHROMEBOX"
}
