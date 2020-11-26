#!/bin/bash

set -e
set -x

scriptdir=$(dirname "${BASH_SOURCE[0]}")
package=$1
userid=$2

flatpak install -y flathub "$package"

$scriptdir/flatpak-tar.sh /output
chown $userid /output/*.tar.gz

