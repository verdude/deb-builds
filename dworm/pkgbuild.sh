#!/usr/bin/env bash

set -xeo pipefail

name="dworm"
semver="0.1.0"
revision=1
vcs_url="https://github.com/verdude/dworm"
description="i live like a worm"

files=(
  /etc/dworm.d/env
  /etc/dworm.d/dworm.service
  /usr/local/bin/dworm.run
)
makedepends=('erlang' 'git' 'make')

__scriptpath="$(cd "$(dirname "$0")"; pwd -P)"
__version="${name}_${semver}-${revision}"
__pkgbuilddir="${__version}"
__builddir=""

function build() {
  cd ${__builddir}
  make SFX=1
}

function install() {
  cd ${__builddir}
  make DESTDIR=${__pkgbuilddir} install
}

function _prepare_env() {
  mkdir -p ${__pkgbuilddir}
  cd ${__pkgbuilddir}
  for file in ${files[@]}; do
    echo $file
    mkdir -p $(dirname $file)
  done
}

function _checkout() {
  __builddir=$(mktemp -d)
  cd ${__builddir}
  git clone --depth 1 ${vcs} ${name}
  cd ${name}
}

function _prepdeps() {
  apt update
  apt install -y ${makedepends[@]}
}

function _control() {
  cd ${__scriptpath}/${__pkgbuilddir}
  mkdir -p DEBIAN
  cd DEBIAN
  cp ${__scriptpath}/../control .
  sed -i "s/\${NAME}/${name}/" control
  sed -i "s/\${VERSION}/${__version}/" control
  sed -i "s/\${DEPENDS}/${depends[@]}/" control
  sed -i "s/\${MAINTAINER}/${maintainer:-${EMAIL}}/" control
  sed -i "s/\${DESCRIPTION}/${description}/" control
}

_prepdeps
_prepare_env
_control
_checkout
build
install
