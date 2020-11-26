#
# spec file for package org.gnome.Platform
#
# Copyright (c) 2020 SUSE LINUX GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


Name:           $PACKAGE_NAME
Version:        $PACKAGE_VERSION
Release:        0
Summary:        Flatpak image %{name}
# TODO
License:        unknown
# group?
Group:          Development/Libraries/Perl
Requires:       %{name}-v%{version}
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

%description

An rpm version of the flatpak image %{name}

%prep

%build

%install

mkdir -p %{buildroot}/var/lib/flatpak/tars
echo 'Dummy package' > %{buildroot}/var/lib/flatpak/tars/%{name}-%{version}.README

%files
/var/lib/flatpak
/var/lib/flatpak/tars

%changelog
