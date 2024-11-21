package Entities::MonitoringClientInfo;

use strict;
use warnings;

use HTML::Escape ("escape_html");
use Time::Piece;


sub new {
	my ( $class, %args ) = @_;

	my $self = {
		hostname           => $args{hostname}           || '',
		kernel 			   => $args{kernel} 			|| '',
		version            => $args{version}            || '',
		uptime             => $args{uptime}             || '',
		memoryCapacity     => $args{memoryCapacity}     || 0,
		lastConnectionTime => $args{lastConnectionTime} || ''
	};

	bless $self, $class; # bless explained in readme.md: OOP -> Classes -> Bless
	return $self;
}


sub getters {
	return ("version", "uptime", "memoryCapacity", "kernel");
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


sub memoryCapacity {
	$_[0]->{memoryCapacity} = $_[1] if defined $_[1];
	$_[0]->{memoryCapacity};
}


sub lastConnectionTime {
	$_[0]->{lastConnectionTime} = $_[1] if defined $_[1];
	$_[0]->{lastConnectionTime};
}


sub kernel {
	$_[0]->{kernel} = $_[1] if defined $_[1];
	$_[0]->{kernel};
}

1;
