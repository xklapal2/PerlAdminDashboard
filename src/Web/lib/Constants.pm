package Constants;

use strict;
use warnings;
use Readonly;
use Exporter 'import';

# Export constants on demand
our @EXPORT_OK =qw(%helpdeskRequestStates $HelpdeskRequestStateNew $HelpdeskRequestStateInProcess $HelpdeskRequestStateDone getStateLabel);

# Define constants using Readonly
Readonly our $HelpdeskRequestStateNew       => 0;
Readonly our $HelpdeskRequestStateInProcess => 1;
Readonly our $HelpdeskRequestStateDone      => 2;

# Define a read-only hash for request states
Readonly our %helpdeskRequestStates => (
	"New"        => $HelpdeskRequestStateNew,
	"In Process" => $HelpdeskRequestStateInProcess,
	"Done"       => $HelpdeskRequestStateDone,
);

# Hash with switched keys and values
Readonly my %helpdeskRequestStateLabels => reverse %helpdeskRequestStates;

# Subroutine to get state label by ID
sub getStateLabel {
	my ($id) = @_;
	return $helpdeskRequestStateLabels{$id}
	  if exists $helpdeskRequestStateLabels{$id};
	return undef;
}

1;
