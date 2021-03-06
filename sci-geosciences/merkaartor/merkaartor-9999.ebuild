# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PLOCALES="ar cs de en es et fr hr hu id_ID it ja nl pl pt_BR pt ru sk sv uk vi zh_CN zh_TW"

inherit fdo-mime gnome2-utils git-r3 l10n qmake-utils

DESCRIPTION="Qt based map editor for the openstreetmap.org project"
HOMEPAGE="http://www.merkaartor.be https://github.com/openstreetmap/merkaartor"
SRC_URI=""
EGIT_REPO_URI="https://github.com/openstreetmap/merkaartor.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="debug exif gps libproxy webengine"

RDEPEND="
	dev-qt/qtconcurrent:5
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtprintsupport:5
	dev-qt/qtsingleapplication[X,qt5]
	dev-qt/qtsvg:5
	dev-qt/qtwidgets:5
	dev-qt/qtxml:5
	sci-libs/gdal
	sci-libs/proj
	sys-libs/zlib
	exif? ( media-gfx/exiv2:= )
	gps? ( >=sci-geosciences/gpsd-3.13[cxx] )
	libproxy? ( net-libs/libproxy )
	webengine? ( dev-qt/qtwebengine:5 )
"
DEPEND="${RDEPEND}
	dev-qt/linguist-tools:5
	virtual/pkgconfig
"

DOCS=( AUTHORS CHANGELOG )

src_unpack() {
	git-r3_src_unpack
}

src_prepare() {
	default

	my_rm_loc() {
		sed -i -e "s:../translations/${PN}_${1}.\(ts\|qm\)::" src/src.pro || die
		rm "translations/${PN}_${1}.ts" || die
	}

	if [[ -n "$(l10n_get_locales)" ]]; then
		l10n_for_each_disabled_locale_do my_rm_loc
		$(qt5_get_bindir)/lrelease src/src.pro || die
	fi

	# build system expects to be building from git
	if [[ ${PV} != *9999 ]] ; then
		sed -i "${S}"/src/Config.pri -e "s:SION = .*:SION = \"${PV}\":g" || die
	fi
}

src_configure() {
	# TRANSDIR_SYSTEM is for bug #385671
	eqmake5 \
		PREFIX="${ED}usr" \
		LIBDIR="${ED}usr/$(get_libdir)" \
		TRANSDIR_MERKAARTOR="${ED}usr/share/${PN}/translations" \
		TRANSDIR_SYSTEM="${EPREFIX}/usr/share/qt5/translations" \
		SYSTEM_QTSA=1 \
		NODEBUG=$(usex debug 0 1) \
		GEOIMAGE=$(usex exif 1 0) \
		GPSDLIB=$(usex gps 1 0) \
		LIBPROXY=$(usex libproxy 1 0) \
		USEWEBENGINE=$(usex webengine 1 0) \
		Merkaartor.pro
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}
