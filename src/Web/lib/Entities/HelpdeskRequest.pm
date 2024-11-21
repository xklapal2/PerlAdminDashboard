package Entities::HelpdeskRequest;

use strict;
use warnings;

use HTML::Escape ("escape_html");
use Constants    ('$HelpdeskRequestStateNew');

# constructor
sub new {
	my ( $class, %args ) = @_;

	my $self = {
		id        => $args{id}        || 0,
		messageId => $args{messageId} || undef,
		sender    => $args{sender}    || '',
		subject   => $args{subject}   || '',
		body      => $args{body}      || '',
		date      => $args{date}      || '',
		progress  => $args{progress}  || $HelpdeskRequestStateNew,
	};

	bless ($self, $class); # bless explained in readme.md: OOP -> Classes -> Bless
	return $self;
}


sub bodyReplaceLineEndsWithBreaks {
	my ($self) = @_;
	my $htmlBody = $self->{body};

	$htmlBody = escape_html($htmlBody);

	# apply regex-replace
	$htmlBody =~ s/\r\n?/\n/g;      # replace \r\n with \n
	$htmlBody =~ s/\n/<br \/>/g;    # replace \n with <br />

	$htmlBody =~ s/\\/\\\\/g;       # Escape backslashes
	$htmlBody =~ s/'/\\'/g;         # Escape single quotes
	$htmlBody =~ s/"/\\"/g;         # Escape double quotes

	return $htmlBody;
}

# Getters and setters
sub id {
	$_[0]->{id} = $_[1] if defined $_[1];
	$_[0]->{id};
}


sub messageId {
	$_[0]->{messageId} = $_[1] if defined $_[1];
	$_[0]->{messageId};
}


sub sender {
	$_[0]->{sender} = $_[1] if defined $_[1];
	$_[0]->{sender};
}


sub subject {
	$_[0]->{subject} = $_[1] if defined $_[1];
	$_[0]->{subject};
}


sub body {
	$_[0]->{body} = $_[1] if defined $_[1];
	$_[0]->{body};
}


sub date {
	$_[0]->{date} = $_[1] if defined $_[1];
	$_[0]->{date};
}


sub progress {
	$_[0]->{progress} = $_[1] if defined $_[1];
	$_[0]->{progress};
}

1;
