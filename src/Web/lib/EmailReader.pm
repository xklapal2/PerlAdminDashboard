package EmailReader;

use strict;
use warnings;

use Mail::IMAPClient;
use IO::Socket::SSL;
use MIME::Parser;
use Data::Dumper;    # For debugging

use DateTimeParser qw/parseEmailDateTime/;

use Exporter 'import';             # Import the Exporter module
our @EXPORT_OK = qw(getEmails);    # Functions to export

# Opens connection to the mailbox in order to read emails and creates new ARRAY of HASHes where every array-item represents single email
sub getEmails {
    my ($emailConfig) = @_;

    my $imap = createImapClient($emailConfig);

    if ( !$imap ) {
        die "Unable to connect to IMAP server: $@\n";
    }

    $imap->select('INBOX')
      or die "Unable to select INBOX: $@\n";    # Open INBOX folder

    # Search for all messages in the inbox
    my @messages = $imap->search('ALL') or die "Search failed: $@\n";

    my @emails;

    foreach my $messageId (@messages) {

        print "\n\nMSG_ID: $messageId\n\n";

        my $rawBody = $imap->message_string($messageId);    # Get body raw

        my $body = processRawBody($rawBody);

        # Get other parameters
        my $sender  = $imap->get_header( $messageId, "From" );
        my $date    = $imap->get_header( $messageId, "Date" );
        my $subject = $imap->get_header( $messageId, "Subject" );

        push @emails, {
            messageId => $messageId,
            sender    => $sender,
            date      => parseEmailDateTime($date),    # parse dateTime
            subject   => $subject,
            body      => $body
        };
    }

    # Logout and close connection
    $imap->logout();

    return @emails;
}

sub createImapClient {
    my ($emailConfig) = @_;

    return Mail::IMAPClient->new(
        Server   => $emailConfig->{imapHost},
        User     => $emailConfig->{username},
        Password => $emailConfig->{password},
        Port     => $emailConfig->{imapPort},
        Ssl      => 1,
        Uid      => 1,
    );
}

sub processRawBody {
    my ($rawBody) = @_;

    # Parse the email body (optional, use MIME::Parser for complex emails)
    my $parser = MIME::Parser->new;
    $parser->decode_bodies(1);

    # Decode the bodies automatically
    my $entity = $parser->parse_data($rawBody);

    # Print the entity for debugging (structure inspection)
    # print Dumper($entity);
    my $body;
    if ( $entity->parts > 1 ) {
        $body = processMultiPartMessage( $entity->parts );
    }
    else {
        $body = processSinglePartMessage( $entity->bodyhandle );
    }

# If we couldn't find the text/plain part, try getting the entire message as a fallback
    if ( !defined $body ) {
        $body = $entity->as_string;
    }

    return $body;
}

# Single-part message, just try to get the bodyhandle
sub processSinglePartMessage {
    my ($bodyHandle) = @_;

    if ( my $handle = $bodyHandle ) {
        my $content = $handle->as_string;

        removeParsedBodyFile($handle);

        return $content;
    }
    else {
        return "Unable to retrieve body";
    }
}

# If it's a multipart message, loop through the parts and extract the plain text part
sub processMultiPartMessage {
    my ($emailParts) = @_;

    foreach my $part ($emailParts) {
        if ( $part->head->mime_type eq 'text/plain' ) {
            my $bodyHandle = $part->bodyhandle;
            my $content    = $bodyHandle->as_string;

            removeParsedBodyFile($bodyHandle);

            return $content;
        }
    }
}

sub removeParsedBodyFile {
    my ($bodyhandle) = @_;

    if (   $bodyhandle
        && $bodyhandle->isa('MIME::Body::File')
        && -e $bodyhandle->path )
    {
        # print "\n\n$bodyhandle->{path}\n\n";
        # print Dumper($bodyhandle);
        # print "\n\n$bodyhandle->{path}\n\n";
        # print Dumper($bodyhandle->path);

        unlink $bodyhandle->path;    # Delete the file
    }
}
