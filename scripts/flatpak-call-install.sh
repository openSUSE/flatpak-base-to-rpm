#!/bin/bash

set -e
set -x

scriptdir=$(dirname "${BASH_SOURCE[0]}")
package=$1

docker run -it --rm --privileged \
  -v$PWD/scripts:/scripts \
  -v$PWD/out:/output \
  flatpak-base /scripts/flatpak-install.sh "$package" $UID


