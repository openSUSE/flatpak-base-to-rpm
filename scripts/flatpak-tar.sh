#!/bin/bash

set -e

outputdir=$1

runtimedir=/var/lib/flatpak/runtime
cd $runtimedir

create-tar() {
    local pkg=$1
    local arch=$2
    local version=$3
    cd $runtimedir
    echo "======== tar czf $outputdir/$pkg-v$version.$arch.tar.gz $pkg/$arch/$version"
    tar czf $outputdir/$pkg-v$version.$arch.tar.gz $pkg/$arch/$version
}

process_versions() {
    local pkg=$1
    local arch=$2
    cd "$runtimedir/$pkg/$arch"
    for version in *; do
        create-tar $pkg $arch $version
    done
}

process_archs() {
    local pkg=$1
    cd "$runtimedir/$pkg"
    for arch in *; do
        process_versions $pkg $arch
    done
}

process_packages() {
    for i in *; do
        process_archs $i
    done
}

process_packages

