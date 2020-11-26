FROM opensuse/leap:15.2

RUN zypper refresh && zypper -n install \
    xeyes \
    gzip \
    flatpak \
    flatpak-builder \
    xz \
    librsvg \
    gdk-pixbuf-loader-rsvg \
  && true

RUN flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo


