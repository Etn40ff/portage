# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="drive is a tiny program to pull or push Google Drive files."
HOMEPAGE="https://github.com/odeke-em/drive"
SRC_URI="https://github.com/odeke-em/drive/archive/v${PV}.tar.gz -> ${P}.tar.gz"

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
	echo $GOROOT
	
	ln -s ../drive-gen/Godeps/_workspace/src/github.com/ src/
	ln -s ../drive-gen/Godeps/_workspace/src/golang.org/ src/
	ln -s ../drive-gen/Godeps/_workspace/src/google.golang.org/ src/

	mkdir -p src/github.com/odeke-em/drive/
	ln -s ../../../../../../../config src/github.com/odeke-em/drive/config
	ln -s ../../../../../../../src src/github.com/odeke-em/drive/src
	ln -s ../../../../../../../gen src/github.com/odeke-em/drive/gen

	go get github.com/odeke-em/command
	go get github.com/odeke-em/extractor
	go get github.com/odeke-em/go-utils/pkger
	go get github.com/odeke-em/meddler
	go get github.com/odeke-em/pretty-words
	go get github.com/skratchdot/open-golang/open
	go get google.golang.org/api/drive/v2

}

src_compile() {
	cd cmd/drive
	go build -o "${PN}" main.go
}

src_install() {
	dodoc README.md
	dobin "cmd/drive/${PN}"
}
