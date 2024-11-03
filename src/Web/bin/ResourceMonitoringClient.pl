#!/usr/bin/perl

use Sys::Statistics::Linux;
use Data::Dumper;    # For debugging

my $lxs = Sys::Statistics::Linux->new(
    sysinfo   => 1,
    cpustats  => 0,
    memstats  => 0,
    processes => 0,

    procstats => 0,
    pgswstats => 0,
    netstats  => 0,
    sockstats => 0,
    diskstats => 0,
    diskusage => 0,
    loadavg   => 0,
    filestats => 0,
);
$lxs->init;

# while (1) {
sleep 1;
my $stat = $lxs->get;
print Dumper($lxs);
print "CPU Usage: ",   $stat->cpustats->{cpu}->{total}, "%\n";
print "Memory Free: ", $stat->memstats->{memfree},      " KB\n";
my $cpu  = $lxs->get(1)->cpustats;
my $time = $lxs->gettime;
printf "%-20s%8s%8s%8s%8s%8s%8s%8s%8s\n", $time, @{ $cpu->{cpu} }{@order};

# ram
my @top5 = $stat->pstop( ttime => 1 );

$fileName = "f.txt";
open( fileHandle, '>', $fileName );
print fileHandle Dumper(@top5);
close(fileHandle);

# disk

# }

