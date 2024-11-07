package DateTimeHelper;

use strict;
use warnings;

use DateTime;
use DateTime::Format::Strptime;
use DateTime::Format::ISO8601;

use Exporter 'import';                      # Import the Exporter module
our @EXPORT_OK = ("parseEmailDateTime", "formatDate");    # Functions to export

# Incomming format of datetime from mail headers is: "Sun, 20 Oct 2024 14:38:24 +0000"
# Accepts format: "Sun, 20 Oct 2024 14:38:24 +0000";
# Returns: datetime in format: YYYY-MM-DD HH:MM:SS
sub parseEmailDateTime {
	my ($datetimeString) = @_;
	print "Parsing $datetimeString \n";

	# Create a Strptime formatter for the given format
	my $strp = DateTime::Format::Strptime->new(
		pattern  => '%a, %d %b %Y %H:%M:%S %z',
		locale   => 'en_US',
		on_error => 'croak',
	);

	my $dt = $strp->parse_datetime($datetimeString);

	if (!defined $dt) {
		warn ("Failed to parse datetime.");
		return undef;
	} else {
		return $dt->strftime('%Y-%m-%dT%H:%M:%S');
	}

}


sub formatDate {
	my ($iso8601_str) = @_;

	# Parse the ISO8601 date string
	my $dt = DateTime::Format::ISO8601->parse_datetime($iso8601_str);

	# Format it as "November 4, 2024, 21:34:25"
	return $dt->strftime('%Y/%m/%d %H:%M:%S');
}

1;
