package Entities::MonitoringStatus;

use strict;
use warnings;


sub new {
	my ($class, %args) = @_;

	my $self = {
		hostname => $args{hostname} || '',
		timestamp => $args{timestamp} || '',
		cpu => $args{cpu} || 0
	};

	bless ($self, $class);
	return $self;
}

# Getters and setters
sub hostname {
	$_[0]->{hostname} = $_[1] if defined $_[1];
	$_[0]->{hostname};
}


sub timestamp {
	$_[0]->{timestamp} = $_[1] if defined $_[1];
	$_[0]->{timestamp};
}


sub cpu {
	$_[0]->{cpu} = $_[1] if defined $_[1];
	$_[0]->{cpu};
}