
use Sys::Statistics::Linux;
use Data::Dumper;    # For debugging

use LWP::UserAgent;
use HTTP::Request;
use JSON;
use Time::Piece;

# Global scope
our $ua  = LWP::UserAgent->new;
our $baseUrl = "http://localhost:5000/monitoring";
our $registerUrl = "$baseUrl/register";
our $resourcesUrl = "$baseUrl/resources/";
our $hostname = "";

our $lxs = Sys::Statistics::Linux->new(
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


sub getHostname{
	my ($lxs) = @_;
	my $stat = $lxs->get;
	my $sysInfo = $stat->sysinfo();
	return $sysInfo->{hostname};
}


sub init{
	$hostname = getHostname($lxs);
	print "hostname: $hostname \n";
	register($lxs);
}


sub memtotalToGigabytes {
	my ($memtotalStr) = @_;

	$memtotalStr =~ s/\D//g; # DigitOnly
	my $memtotalInt = $memtotalStr + 0; # ToInt32
	return sprintf("%.2f", $memtotalInt / ( 1024 * 1024 )); # KB to GB => Round to two deciaml places
}


sub createRegistrationData {
	my ($lxs) = @_;

	my $stat = $lxs->get;
	$sysInfo = $stat->sysinfo();

	$uptime          = $sysInfo->{uptime};
	$memtotal        = memtotalToGigabytes( $sysInfo->{memtotal} );
	$version         = $sysInfo->{version};
	$hostname        = $hostname;
	$kernel 		 = $sysInfo->{kernel};

	return {
		hostname        => $hostname,
		version         => $version,
		uptime          => $uptime,
		memoryCapacity  => $memtotal,
		kernel 			=> $kernel,
	};
}


sub register {
	my ($lxs) = @_;
	my $registrationJson = encode_json( createRegistrationData($lxs) );

	my $request = HTTP::Request->new( POST => $registerUrl );
	$request->header( 'Content-Type' => 'application/json' );
	$request->content($registrationJson);

	my $response = $ua->request($request); # HTTP client send

	if ( $response->is_success ) {
		print "Registration: ". $response->decoded_content . "\n";
	}else {
		die "HTTP POST error code: ". $response->code . "\n". "HTTP POST error message: ". $response->message . "\n";
	}
}


sub createSystemMonitoringData {
	my ($lxs) = @_;

	my $timestamp = getTime($lxs);
	my $cpuTotal = $lxs->get(1)->cpustats->{cpu}->{total}; # Refresh statistics and get total CPU usage

	return {
		timestamp => $timestamp,
		cpuTotal => $cpuTotal
	};

}


sub postStatus {
	my ($lxs) = @_;
	my $monitoringJson = encode_json( createSystemMonitoringData($lxs) );
	print "$monitoringJson\n";

	my $request = HTTP::Request->new( POST => $resourcesUrl . $hostname );
	$request->header( 'Content-Type' => 'application/json' );
	$request->content($monitoringJson);

	# UDP behavior I don't care about response
	$ua->request($request); # HTTP client send
}


sub getTime{
	my ($lxs) = @_;
	my ($date, $time) = $lxs->gettime();
	return $date . "T" . $time;
}


init();

while (1) {
	sleep 3;
	postStatus($lxs);

	# ram
	# print "Memory Free: ", $stat->memstats->{memfree},      " KB\n";
	# my @top5 = $stat->pstop( ttime => 1 );

	# $fileName = "f.txt";
	# open( fileHandle, '>', $fileName );
	# print fileHandle Dumper(@top5);
	# close(fileHandle);

	# disk

}

