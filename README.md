## Install flatpak base images and create rpm specs and tar archives

Build the container for installing flatpak base images:

    make docker-base

Example:

    # Check for necessary updates
    % perl scripts/flatpak-check-updates.pl
    → org.freedesktop.Platform can be updated (v20.08.3 -> v20.08.5)
    → org.freedesktop.Sdk can be updated (v20.08.3 -> v20.08.5)
    ✓ org.gnome.Platform is uptodate (v3.38)
    ✓ org.gnome.Sdk is uptodate (v3.38)
    ✓ org.kde.Platform is uptodate (v5.15)
    ✓ org.kde.Sdk is uptodate (v5.15)

    # Checkout OBS:Flatpak
    % cd ~/osc
    # Warning! Needs 11G disk space (currently)
    % osc co OBS:Flatpak

    # Update org.freedesktop.Sdk
    # Install a runtime in docker environment and create tarballs under `output/`
    # Use '20.08' (the flatpak branch name), not the full version
    % scripts/flatpak-call-install.sh runtime/org.freedesktop.Sdk/x86_64/20.08
    # Create spec files from tarballs under `osc/package-name/`
    % perl scripts/flatpak-spec.pl org.freedesktop.Sdk
    # Then move the resulting files in the `osc/` directories to your osc checkout
    % rsync -a osc/org.* ~/osc/OBS:Flatpak/
    # Remove generated files
    % rm -rf osc/org.*

    # Update org.freedesktop.Platform
    % scripts/flatpak-call-install.sh runtime/org.freedesktop.Platform/x86_64/20.08
    % perl scripts/flatpak-spec.pl org.freedesktop.Platform
    % rsync -a osc/org.* ~/osc/OBS:Flatpak/
    % rm -rf osc/org.*

    # Commit the updated OBS packages
    % cd ~/osc/OBS:Flatpak/
    # look for updated packages and commit

### Requirements

* bash
* perl >= 5.22
* perl-YAML-PP
* perl-Getopt-Long-Descriptive
* perl-XML-LibXML

The flatpak commands are running in a docker container, so you only need docker
for that, but the perl scripts run on your machine.

## Build the container for building flatpak images

For trying out building apps in docker:

    make docker-builder

Note that you have to run docker with the `--privileged` option.
