#!/usr/bin/env bash

set -xueo pipefail

# required
name=""
semver=""
vcs_url=""
files=""
# optional
makedepends=""
buildargs=""
description=""
revision=""

while getopts f:m:n:v:r:v:d:a: flag
do
  case ${flag} in
    n) name="${OPTARG}";;
    v) semver="${OPTARG}";;
    r) revision=${OPTARG:-1};;
    v) vcs_url="${OPTARG}";;
    d) description="${OPTARG}";;
    a) buildargs="${OPTARG}";;
    m) makedepends="${OPTARG}";;
    f) files="${OPTARG}";;
    ?) echo "Bad Args."; exit 1;;
  esac
done

__scriptpath="$(cd "$(dirname "$0")"; pwd -P)"
__version="${name}_${semver}-${revision}"
__pkgbuilddir="${__version}"
__builddir=""

function build() {
  cd ${__builddir}
  make ${BUILD_ARGS}
}

function install() {
  cd ${__builddir}
  make DESTDIR=${__pkgbuilddir} install
}

# re-usable functions
function _prepare_env() {
  mkdir -p ${__pkgbuilddir}
  cd ${__pkgbuilddir}
  for file in ${files}; do
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
  apt install -y ${makedepends}
}

function _control() {
  cd ${__scriptpath}/${__pkgbuilddir}
  mkdir -p DEBIAN
  cd DEBIAN
  cp ${__scriptpath}/../control.template control
  sed -i "s/\${NAME}/${name}/" control
  sed -i "s/\${VERSION}/${__version}/" control
  sed -i "s/\${DEPENDS}/${depends[@]}/" control
  sed -i "s/\${MAINTAINER}/${maintainer:-${EMAIL}}/" control
  sed -i "s/\${DESCRIPTION}/${description}/" control
}

function _verify() {
  for arg in $@; do
    if [[ -z "${!arg}" ]]; then
      echo "missing required args"
      exit 1
    fi
  done
}

_verify name semver vcs_url files
_prepdeps
_prepare_env
_control
_checkout
build
install
