#!/usr/bin/perl
use strict;
use warnings;
use 5.022;
use experimental qw/ signatures /;
use FindBin '$Bin';
use autodie qw/ open opendir close closedir rename /;
use Data::Dumper;
use YAML::PP::Highlight;
use Getopt::Long::Descriptive;

my ($opt, $usage) = describe_options(
    <<'EOM',
flatpak-spec.pl %o <package>

e.g. flatpak-spec.pl org.gnome.Platform
EOM
    [ 'help|h' => "print usage message and exit", { shortcircuit => 1 } ],
    [ 'verbose|v' => "Verbose output" ],
);
print($usage->text), exit if $opt->help;

# org.gnome.Platform-v3.38.x86_64.tar.gz
# org.gnome.Platform-v3.38.spec
# org.gnome.Platform.spec

my $dir = "$Bin/../out";
my $oscdir = "$Bin/../osc";
my $templatefile = "$Bin/../etc/template.spec";
my $templatefile_versioned = "$Bin/../etc/template-versioned.spec";
my $arch = 'x86_64';

unless (@ARGV) {
    print($usage->text), exit 1;
}
my ($package) = @ARGV;

my $template = do { open my $fh, '<', $templatefile; local $/; <$fh> };
my $template_versioned = do { open my $fh, '<', $templatefile_versioned; local $/; <$fh> };

my @deps;
my %specs;

opendir(my $dh, $dir);
for my $tar (sort readdir $dh) {
    next unless $tar =~ m/^([\w.]+)-v([0-9.]+)\.$arch\.tar\.gz$/;
    my ($pkg, $v) = ($1, $2);
    unless ($pkg eq $package) {
        push @deps, "$pkg-v$v";
    }
    $specs{ "$pkg" } = {
        version => $v,
        source => $tar,
        deps => [],
    };
}
closedir $dh;

unless (keys %specs) {
    warn "$dir does not contain tarballs, abort";
    exit 1;
}

# Get full version, if available
open my $fh, '<', "$dir/versions.tsv";
while (my $line = <$fh>) {
    chomp $line;
    my ($id, $version, $branch, $origin) = split m/\t/, $line;
    $specs{ $id }->{full_version} = $version;
}
close $fh;

$specs{ $package }->{deps} = \@deps;
$opt->verbose and say YAML::PP::Highlight::Dump \%specs;

for my $pkg (sort keys %specs) {
    package2spec($pkg);
}

sub package2spec($pkg) {
    say "======== $pkg";
    my $version = $specs{ $pkg }->{version};
    my $full_version = $specs{ $pkg }->{full_version} || $version;
    my $deps = $specs{ $pkg }->{deps};
    my $source = $specs{ $pkg }->{source};
    my $name = "$pkg-v$version";

    my $spec = $template;
    my $versioned = $template_versioned;
    for ($spec, $versioned) {
        s/\$PACKAGE_VERSION\b/$full_version/g;
    }
    $spec =~ s/\$PACKAGE_NAME\b/$pkg/g;
    $versioned =~ s/\$PACKAGE_NAME\b/$pkg/g;
    $versioned =~ s/\$PACKAGE_NAME_VERSION\b/$name/g;
    my $requires = '';
    for my $dep (@$deps) {
        $requires .= "Requires:       $dep\n";
    }
    $versioned =~ s/\$REQUIRES\b/$requires/;

    mkdir $oscdir;
    mkdir "$oscdir/$name";
    say "Creating $oscdir/$name/$name.spec";
    open my $fh, '>', "$oscdir/$name/$name.spec";
    print $fh $versioned;
    close $fh;

    say "Moving $source to $oscdir/$name";
    rename "$dir/$source", "$oscdir/$name/$source";
}
