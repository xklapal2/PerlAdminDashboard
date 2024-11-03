#!/usr/bin/perl

use Sys::Statistics::Linux;
use Data::Dumper;    # For debugging

use LWP::UserAgent;
use HTTP::Request;
use JSON;
use Time::Piece;

my $ua  = LWP::UserAgent->new;
my $url = 'http://localhost:5000/monitoring/register';

my $lxs = Sys::Statistics::Linux->new(
    sysinfo   => 1,
    cpustats  => 1,
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

sub memtotalToGigabytes {
    my ($memtotalStr) = @_;

    # Removes any non-digit characters
    $memtotalStr =~ s/\D//g;

    # Forces numeric context
    my $memtotalInt = $memtotalStr + 0;

    # Convert kilobytes to gigabytes
    return $memtotalInt / ( 1024 * 1024 );
}

sub createRegistrationData {
    my ($lxs) = @_;

    my $stat = $lxs->get;
    $sysInfo = $stat->sysinfo();

    $uptime          = $sysInfo->{uptime};
    $tcpucount       = $sysInfo->{tcpucount};
    $memtotal        = memtotalToGigabytes( $sysInfo->{memtotal} );
    $version         = $sysInfo->{version};
    $hostname        = $sysInfo->{hostname};
    $clientTimestamp = localtime->datetime;    # Format: YYYY-MM-DDTHH:MM:SS

    return {
        hostname        => $hostname,
        version         => $version,
        uptime          => $uptime,
        cpuCount        => $tcpucount,
        memoryCapacity  => $memtotal,
        clientTimestamp => $clientTimestamp,
    };
}

sub register {
    my ($lxs) = @_;
    my $registrationJson = encode_json( createRegistrationData($lxs) );

    my $request = HTTP::Request->new( POST => $url );
    $request->header( 'Content-Type' => 'application/json' );
    $request->content($registrationJson);

    # Send the request
    my $response = $ua->request($request);

    # Check the response
    if ( $response->is_success ) {
        print "Response: "
          . $response->decoded_content;    # Print the response content
    }
    else {
        die "HTTP POST error code: "
          . $response->code . "\n"
          . "HTTP POST error message: "
          . $response->message . "\n";
    }
}

register($lxs);

# # while (1) {
# sleep 1;
# my $stat = $lxs->get;
# print Dumper($lxs);
# print "CPU Usage: ",   $stat->cpustats->{cpu}->{total}, "%\n";
# print "Memory Free: ", $stat->memstats->{memfree},      " KB\n";
# my $cpu  = $lxs->get(1)->cpustats;
# my $time = $lxs->gettime;
# printf "%-20s%8s%8s%8s%8s%8s%8s%8s%8s\n", $time, @{ $cpu->{cpu} }{@order};

# # ram
# my @top5 = $stat->pstop( ttime => 1 );

# $fileName = "f.txt";
# open( fileHandle, '>', $fileName );
# print fileHandle Dumper(@top5);
# close(fileHandle);

# # disk

# # }

