# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit eutils toolchain-funcs

DESCRIPTION="Drawing editor for creating figures in PDF or PS formats"
HOMEPAGE="http://ipe.otfried.org"
SRC_URI="https://dl.bintray.com/otfried/generic/ipe/${PV%.*}/${P}-src.tar.gz"

RESTRICT="mirror"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="highprec"

RDEPEND="app-text/texlive-core
	>=dev-lang/lua-5.2
	media-libs/freetype:2
	x11-libs/cairo
	dev-qt/qtcore:5
	dev-qt/qtwidgets:5"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

S="${WORKDIR}/${P}/src"
COMMONDIR=/usr/share/ipe/common

search_urw_fonts() {
	# colon-separated list of paths
	local texmfdist="$(kpsewhich -var-value=TEXMFDIST)"
	# according to TeX directory structure
	local urwdir=fonts/type1/urw
	# add colon as field separator
	local IFS="${IFS}:" dir
	for dir in ${texmfdist}; do
		if [[ -d ${dir}/${urwdir} ]]; then
			URWFONTDIR="${dir}/${urwdir}"
			return 0
		fi
	done
	return 1
}

src_prepare() {
	sed -i \
		-e 's/fpic/fPIC/' \
		-e 's_moc_/usr/lib64/qt5/bin/moc_' \
		-e "s:\$(IPEPREFIX)/lib:\$(IPEPREFIX)/$(get_libdir):g" \
		config.mak || die
	sed -i -e 's/install -s/install/' common.mak || die

	if use highprec; then
		einfo "Adding patch for higher output precision"
		epatch "${FILESDIR}"/${PN}-outputprecision.patch
	fi
}

pkg_setup() {
	if search_urw_fonts; then
		einfo "URW fonts found in ${URWFONTDIR}"
	else
		ewarn "Could not find directory containing URW fonts"
		ewarn "Ipe will not function properly without them."
	fi
}

src_compile() {
	emake \
		CXX=$(tc-getCXX) \
		IPEPREFIX="${EPREFIX}/usr" \
		IPEDOCDIR="${EPREFIX}/usr/share/doc/${PF}/html"
}

src_install() {
	emake install \
		IPEPREFIX="${EPREFIX}/usr" \
		IPEDOCDIR="${EPREFIX}/usr/share/doc/${PF}/html" \
		INSTALL_ROOT="${ED}"
	dodoc ../{news,readme}.txt
	doicon ipe/icons/ipe.png
	make_desktop_entry ipe Ipe ipe
	# Link style sheets
	if [ -d $COMMONDIR/styles ]; then
		einfo "Linking common style sheets from $COMMONDIR"
		for f in $COMMONDIR/styles/*; do
			einfo "  Linking ${f##*/}"
			dosym $f usr/share/ipe/${PV}/styles/${f##*/}
		done

		elog "Style sheets from $COMMONDIR/styles have been symlinked to"
		elog "the style sheet directory of ${P}. If you add additional"
		elog "style sheets later to $COMMONDIR/styles you may symlink"
		elog "them by hand to '/usr/share/ipe/${PV}/styles/'."
	fi
}
