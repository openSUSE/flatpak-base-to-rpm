#!/usr/bin/perl
use strict;
use warnings;
use 5.022;
use experimental qw/ signatures /;
use FindBin '$Bin';
use autodie qw/ open opendir close closedir rename /;
use Data::Dumper;
use YAML::PP;
use Getopt::Long::Descriptive;
use XML::LibXML;
use Term::ANSIColor;
my $check = colored(['green bold'], '✓');
my $arrow = colored(['red bold'], '→');

my $runtimes = YAML::PP->new->load_file("$Bin/../etc/runtimes.yaml");

my ($opt, $usage) = describe_options(
    <<'EOM',
flatpak-check-updates.pl %o

EOM
    [ 'help|h' => "print usage message and exit", { shortcircuit => 1 } ],
    [ 'all' => "Show updates for all packages" ],
);
print($usage->text), exit if $opt->help;

my $file = "/tmp/obs-flatpak.xml";
my $cmd = "osc --apiurl https://api.opensuse.org api /status/project/OBS:Flatpak >$file";
my $ls = "flatpak remote-ls --system flathub --columns=application:f,version,branch";

my $out = qx{$cmd};

my $dom = XML::LibXML->load_xml(location => $file);

my @pkg = $dom->findnodes('/packages/package');
for my $node (@pkg) {
    my $namev = $node->getAttribute('name');
    my ($name, $branch) = $namev =~ m/^(.*)-v(.*)$/;
    next unless $branch;
    next if (not $opt->all and not exists $runtimes->{ $name });
    my $version = version->parse('v' . $node->getAttribute('version'));
    $runtimes->{ $name }->{ $branch } = $version;
    my $max = $runtimes->{ $name }->{max} // 0;
    if ($version > $max) {
        $runtimes->{ $name }->{max} = $version;
    }
    $runtimes->{ $name }->{max_flatpak} = 0;
}

chomp(my @list = qx{$ls});
for my $line (@list) {
    my ($name, $version, $branch) = split m/\t/, $line;
    next unless exists $runtimes->{ $name };
    $version ||= $branch;
    # version can be '5.15-21.08' for example
    $version =~ s/-/./g;
    $version = version->parse('v' . $version);
    if ($version > $runtimes->{ $name }->{max_flatpak}) {
        $runtimes->{ $name }->{max_flatpak} = $version;
    }
}

for my $name (sort keys %$runtimes) {
    if ($runtimes->{ $name }->{max_flatpak} > $runtimes->{ $name }->{max}) {
        say "$arrow $name can be updated ($runtimes->{ $name }->{max} -> $runtimes->{ $name }->{max_flatpak})";
    }
    else {
        say "$check $name is uptodate ($runtimes->{ $name }->{max_flatpak})";
    }
}
