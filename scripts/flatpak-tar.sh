#!/bin/bash

set -e
#set -x

outputdir=$1
if [[ -z $outputdir ]] || [[ ! -d $outputdir ]]; then
    echo "Invalid output dir $outputdir"
    exit 1
fi

runtimedir=/var/lib/flatpak/runtime
cd $runtimedir

create-tar() {
    local pkg=$1
    local arch=$2
    local version=$3
    cd $runtimedir
    echo "======== tar czf $outputdir/$pkg-v$version.$arch.tar.gz $pkg/$arch/$version"
    tar czf "$outputdir/$pkg-v$version.$arch.tar.gz" "$pkg/$arch/$version"
}

process-versions() {
    local pkg=$1
    local arch=$2
    cd "$runtimedir/$pkg/$arch"
    for version in *; do
        create-tar "$pkg" "$arch" "$version"
    done
}

process-archs() {
    local pkg=$1
    cd "$runtimedir/$pkg"
    for arch in *; do
        process-versions "$pkg" "$arch"
    done
}

process-packages() {
    for i in *; do
        process-archs "$i"
    done
}

list-versions() {
    flatpak list --columns=application,version,branch,origin | tail -n+1 | grep flathub$
}

process-packages

list-versions > "$outputdir/versions.tsv"
