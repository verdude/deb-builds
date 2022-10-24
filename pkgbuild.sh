#!/usr/bin/env bash

set -xeo pipefail

function build() {
  cd ${__builddir}/${name}
  make ${BUILD_ARGS}
}

function install() {
  cd ${__builddir}/${name}
  make DESTDIR=${__pkgroot} install
}

# re-usable functions
function _prepare_env() {
  mkdir -p ${__pkgroot}
  for file in ${files}; do
    echo $file
    mkdir -p ${__pkgroot}/$(dirname $file)
  done
}

function _checkout() {
  __builddir=$(mktemp -d)
  cd ${__builddir}
  git clone --depth 1 ${vcs_url} ${name}
  cd ${name}
}

function _prepdeps() {
  apt-get update
  apt-get install -y ${makedepends}
}

function _control() {
  cd ${__pkgroot}
  mkdir -p DEBIAN
  cd DEBIAN
  cp ${__pkgbuilddir}/control .
  sed -i "s/\${NAME}/${name}/" control
  sed -i "s/\${VERSION}/${semver}/" control
  sed -i "s/\${DEPENDS}/${depends[@]}/" control
  sed -i "s/\${MAINTAINER}/${maintainer}/" control
  sed -i "s/\${DESCRIPTION}/${description}/" control
  sed -i "s/\${ARCH}/${arch}/" control
}

function _verify() {
  for arg in $@; do
    if [[ -z "${!arg}" ]]; then
      echo "missing required arg: ${arg}"
      exit 1
    fi
  done
}

function _add_scripts() {
  cd ${__pkgbuilddir}
  for script in $@; do
    if [[ -f ${script} ]]; then
      echo ${script}
      chmod 755 ${script}
      cp ${script} ${__pkgroot}/DEBIAN/
    fi
  done
}

function _package() {
  cd $__pkgroot/..
  dpkg-deb --build $__version
  cp $__version.deb $__outputdir
}

function _help() {
  echo "You must provide a PKGBUILD file in the current working directory."
  exit 1
}

while getopts o:h flag
do
  case ${flag} in
    h) _help;;
    o) __outputdir=${OPTARG};;
  esac
done

if [[ ! -f PKGBUILD ]]; then
  _help
fi

source PKGBUILD

# required
name="${PKG_NAME}"
semver="${PKG_VERSION}"
vcs_url="${PKG_VCS_URL}"
files="${PKG_FILES}"
maintainer="${PKG_MAINTAINER}"
arch="${ARCH}"

# optional
description="${PKG_DESCRIPTION}"
makedepends="${MAKE_DEPENDS}"
buildargs="${BUILD_ARGS}"
revision="${PKG_REVISION:-1}"

# internal
__scriptpath="$(cd "$(dirname "$0")"; pwd -P)"
__version="${name}_${semver}-${revision}"
__pkgroot="$(mktemp -d)/${__version}"
__outputdir="${__outputdir:-$PWD}"
__pkgbuilddir="${__scriptpath}"
__builddir=""

set -u

_verify name semver vcs_url files maintainer arch
_prepdeps
_prepare_env
_control
_add_scripts postinst prerm
_checkout
build
install
_package
