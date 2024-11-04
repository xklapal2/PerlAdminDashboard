package Entities::MonitoringClientInfo;

use strict;
use warnings;

use HTML::Escape qw(escape_html);
use Time::Piece;


sub new {
	my ( $class, %args ) = @_;

	my $self = {
		hostname           => $args{hostname}           || '',
		version            => $args{version}            || '',
		uptime             => $args{uptime}             || '',
		cpuCount           => $args{cpuCount}           || 0,
		memoryCapacity     => $args{memoryCapacity}     || 0,
		clientTimestamp    => $args{clientTimestamp}    || '',
		lastConnectionTime => $args{lastConnectionTime} || '',
	};

	bless $self, $class; # bless explained in readme.md: OOP -> Classes -> Bless
	return $self;
}


sub getters {
	return qw(version uptime cpuCount memoryCapacity clientTimestamp);
}


sub update {
	my ( $self, $newInfo ) = @_;
	my %updatedAttributes;

	for my $key ( $newInfo->getters() ) {
		if ( $self->$key ne $newInfo->$key ) {
			$updatedAttributes{$key} = $newInfo->$key;
		}
	}

	my $currentTime = localtime->datetime;    # Format: YYYY-MM-DDTHH:MM:SS
	$updatedAttributes{'lastConnectionTime'} = $currentTime;

	return %updatedAttributes;
}

# getters and setters
sub hostname {
	$_[0]->{hostname} = $_[1] if defined $_[1];
	$_[0]->{hostname};
}


sub version {
	$_[0]->{version} = $_[1] if defined $_[1];
	$_[0]->{version};
}


sub uptime {
	$_[0]->{uptime} = $_[1] if defined $_[1];
	$_[0]->{uptime};
}


sub cpuCount {
	$_[0]->{cpuCount} = $_[1] if defined $_[1];
	$_[0]->{cpuCount};
}


sub memoryCapacity {
	$_[0]->{memoryCapacity} = $_[1] if defined $_[1];
	$_[0]->{memoryCapacity};
}


sub clientTimestamp {
	$_[0]->{clientTimestamp} = $_[1] if defined $_[1];
	$_[0]->{clientTimestamp};
}


sub lastConnectionTime {
	$_[0]->{lastConnectionTime} = $_[1] if defined $_[1];
	$_[0]->{lastConnectionTime};
}

1;
