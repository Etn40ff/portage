# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="drive is a tiny program to pull or push Google Drive files."
HOMEPAGE="https://github.com/odeke-em/drive"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=">=dev-lang/go-1.2
		dev-vcs/git
		dev-vcs/mercurial"
RDEPEND=""

src_prepare() {
	export GOPATH="${PWD}"
	echo $GOPATH
	go get github.com/odeke-em/drive/drive-gen
}

src_compile() {
	cd bin
	./drive-gen
}

src_install() {
	echo `pwd`
	false
	dodoc src/github.com/odeke-em/drive/README.md
	dobin drive
}
