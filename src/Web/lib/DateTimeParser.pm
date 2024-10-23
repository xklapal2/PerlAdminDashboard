package DateTimeParser;

use strict;
use warnings;

use DateTime;
use DateTime::Format::Strptime;

use Exporter 'import';                      # Import the Exporter module
our @EXPORT_OK = qw(parseEmailDateTime);    # Functions to export

# Incomming format of datetime from mail headers is: "Sun, 20 Oct 2024 14:38:24 +0000"
# Accepts format: "Sun, 20 Oct 2024 14:38:24 +0000";
# Returns: datetime in format: YYYY-MM-DD HH:MM:SS
sub parseEmailDateTime {
    my ($datetimeString) = @_;

    # Create a Strptime formatter for the given format
    my $strp = DateTime::Format::Strptime->new(
        pattern  => '%a, %d %b %Y %H:%M:%S %z',
        locale   => 'en_US',
        on_error => 'croak',
    );

    my $dt = $strp->parse_datetime($datetimeString);

    return $dt->strftime('%Y-%m-%d %H:%M:%S');
}
