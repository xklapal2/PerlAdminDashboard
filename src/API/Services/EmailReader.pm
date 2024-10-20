package Services::EmailReader;

use strict;
use warnings;
use Mail::IMAPClient;
use IO::Socket::SSL;
use MIME::Parser;
use Exporter 'import'; # Import the Exporter module

our @EXPORT_OK = qw(getEmails); # Functions to export

sub getEmails{
    my ($emailConfig) = @_;

    # Connect to Gmail IMAP server
    my $imap = Mail::IMAPClient->new(
        Server   => $emailConfig->{imapHost},
        User     => $emailConfig->{username},
        Password => $emailConfig->{password},
        Port     => $emailConfig->{imapPort},
        Ssl      => 1,
        Uid      => 1,  # Use UID for message identification
    ) or die "Unable to connect to IMAP server: $@\n";

    $imap->select('INBOX') or die "Unable to select INBOX: $@\n";

    # Search for all messages in the inbox
    my @messages = $imap->search('ALL') or die "Search failed: $@\n";

    my @emails = [];

    foreach my $messageId (@messages) {
        # Get body
        my $emailBody = $imap->message_string($messageId);

        # Parse the email body (optional, use MIME::Parser for complex emails)
        my $parser = MIME::Parser->new;
        my $entity = $parser->parse_data($emailBody);

        # Check if the bodyhandle is defined before calling as_string
        my $body;
        if (my $body_handle = $entity->bodyhandle) {
            $body = $body_handle->as_string;
        } else {
            $body = "Unable to retrieve body";
        }

        # Get other parameters
        my $sender = $imap->get_header($messageId, "From");
        my $date = $imap->get_header($messageId, "Date");
        my $subject = $imap->get_header($messageId, "Subject");

        push @emails, {
            sender  => $sender,
            date    => $date,
            subject => $subject,
            body    => $body
        };

        # Output the details
        print "Sender: $sender\n";
        print "Subject: $subject\n";
        print "Date: $date\n";
        print "Body: $body\n";
        print "==========================\n";
    }

    # Logout and close connection
    $imap->logout();

    return @emails;
}