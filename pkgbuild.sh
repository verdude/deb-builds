#!/usr/bin/env bash

set -xeo pipefail

function build() {
  cd ${__builddir}/${name}
  make ${BUILD_ARGS}
}

function install() {
  cd ${__builddir}/${name}
  make DESTDIR=${__pkgbuilddir} install
}

# re-usable functions
function _prepare_env() {
  mkdir -p ${__pkgbuilddir}
  cd ${__pkgbuilddir}
  for file in ${files}; do
    echo $file
    mkdir -p ${__pkgbuilddir}/$(dirname $file)
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
  cd ${__pkgbuilddir}
  mkdir -p DEBIAN
  cd DEBIAN
  cp ${__scriptpath}/control .
  sed -i "s/\${NAME}/${name}/" control
  sed -i "s/\${VERSION}/${semver}/" control
  sed -i "s/\${DEPENDS}/${depends[@]}/" control
  sed -i "s/\${MAINTAINER}/${maintainer}/" control
  sed -i "s/\${DESCRIPTION}/${description}/" control
}

function _verify() {
  for arg in $@; do
    if [[ -z "${!arg}" ]]; then
      echo "missing required arg: ${arg}"
      exit 1
    fi
  done
}

function _package() {
  cd $__pkgbuilddir/..
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

# optional
description="${PKG_DESCRIPTION}"
makedepends="${MAKE_DEPENDS}"
buildargs="${BUILD_ARGS}"
revision="${PKG_REVISION:-1}"

# internal
__scriptpath="$(cd "$(dirname "$0")"; pwd -P)"
__version="${name}_${semver}-${revision}"
__pkgbuilddir="$(mktemp -d)/${__version}"
__builddir=""
__outputdir="${__outputdir:-$PWD}"

set -u

_verify name semver vcs_url files maintainer
_prepdeps
_prepare_env
_control
_checkout
build
install
_package
