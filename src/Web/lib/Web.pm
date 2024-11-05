package Web;

use strict;
use warnings;

# 3rd party
use Dancer2;
use Dancer2::Plugin::Database;
use URI;
use Data::Dumper;    # For debugging
use Time::Piece;

# custom modules
use Entities::HelpdeskRequest;
use Entities::MonitoringClientInfo;
use PasswordHasher qw/hashPassword verifyPassword/;
use EmailReader    qw/getEmails/;
use DateTimeHelper ("formatDate");
use Constants qw(%helpdeskRequestStates $HelpdeskRequestStateNew getStateLabel);

our $VERSION = '0.1';

####################################################
###                    Endpoints                 ###
####################################################

# Home - Helpdesk
get '/' => sub {
	my @requests;
	eval {
		my @requestsDictionaries = database->quick_select( 'helpdeskRequests', {} );
		@requests =map { Entities::HelpdeskRequest->new(%$_) } @requestsDictionaries;
	};

	# print Dumper(@requests);
	if ($@) {
		error "Failed to load helpdesk requests from database: $@";

		# TODO: log $@
		return template( 'error',{ errorMsg => "Failed to load helpeds requests." } );
	}

	return template(
		'index' => {
			'title'          => 'Helpdesk',
			'requests'       => @requests ? \@requests : [],
			'helpdeskStates' => \%helpdeskRequestStates,
			"formatDate" => \&formatDate
		}
	);
};

# Handle Fetch Emails
get '/fetchEmails' => sub {

	my $emailConfig = config->{email};
	my @emails = getEmails($emailConfig);
	my @emailsToRemove = [];

	foreach my $email (@emails) {
		eval {
			database->quick_insert(
				'helpdeskRequests',
				{
					messageId => $email->{messageId},
					sender    => $email->{sender},
					subject   => $email->{subject},
					body      => $email->{body},
					date      => $email->{date},
					progress  => $HelpdeskRequestStateNew
				}
			);

			push( @emailsToRemove, $email->{messageId} );
			debug "mail inserted: $email->{subject} \n";
		};

		# TODO : From email remove all @emailsToRemove
		# TODO : EmailReader module : Fix bug - Delete all files which are created during reading inbox.

		if ($@) {
			error "Failed to insert email to database: date: $email->{date}, sender: $email->{sender}";
		}
	}

	# TODO: Remove @emailsToRemove uisng IMAP

	my $emailsJson = to_json( \@emails, { pretty => 1, canonical => 1 } );

	return redirect('/');
};

post '/updateProgress' => sub {
	my $data        = from_json( request->body );
	my $id          = $data->{id};
	my $newProgress = $data->{newProgress};

	if ( !getStateLabel($newProgress) ) {
		status 'bad_request';
		return to_json( { message => 'Invalid progress!' } );
	}

	eval {
		database->quick_update(
			'helpdeskRequests',
			{ id       => $id },            # Where condition
			{ progress => $newProgress }    # Set values
		);
	};

	if ($@) {
		status 'internal_server_error';
		return to_json( { message => 'Oops... Something went wrong!' } );
	}

	return to_json( { status => 'Saved successfully.' } );
};

# Login page
get '/login' => sub {
	my $returnUrl = query_parameters->get('returnUrl')
	  || '/';    # Default return URL if none provided

	# Ensure the returnUrl is URI-encoded to handle special characters
	$returnUrl = URI->new($returnUrl)->as_string;

	return template( 'login', { returnUrl => $returnUrl } );
};

# Handle login
post '/login' => sub {
	my $username  = body_parameters->get('username');
	my $password  = body_parameters->get('password');
	my $returnUrl = body_parameters->get('returnUrl')
	  || '/';    # Default return URL if none provided

	my $user = database->quick_select( 'users', { username => $username } );

	if ( $user && verifyPassword( $user->{password}, $password ) ) {
		session user => $user->{username};
		return redirect($returnUrl);
	}else {
		return template( 'login',{ returnUrl => $returnUrl, loginFailed => 1 } );
	}
};

get '/monitoring' => sub {
	my @clients;
	eval {
		my @dbClients = database->quick_select( 'monitoringClients', {} );
		@clients = map { Entities::MonitoringClientInfo->new(%$_) } @dbClients;
	};

	# print Dumper(@clients);
	if ($@) {
		error "Failed to load clients from database: $@";
		return template( 'error', { errorMsg => "Failed to load clients." } );
	}

	return template(
		'monitoring' => {
			'title'   => 'MonitoringClients',
			'clients' => @clients ? \@clients : [],
			"formatDate" => \&formatDate
		}
	);
};

post '/monitoring/register' => sub {

	eval {
		my $body = request->body;

		# Decode JSON returns hashReference and constructor requires direct accesss to hash
		my $registration = Entities::MonitoringClientInfo->new(%{ decode_json( request->body ) } );

		my $client = database->quick_select( 'monitoringClients',{ hostname => $registration->hostname } );

		if ($client) {
			my $clientBlessed = Entities::MonitoringClientInfo->new( %{ $client } );
			database->quick_update('monitoringClients', { hostname => $clientBlessed->{hostname} }, $clientBlessed->update($registration));
		} else {
			database->quick_insert(
				'monitoringClients',
				{
					hostname           => $registration->{hostname},
					kernel             => $registration->{kernel},
					version            => $registration->{version},
					uptime             => $registration->{uptime},
					memoryCapacity     => $registration->{memoryCapacity},
					lastConnectionTime => localtime->datetime
				}
			);
		}
	};

	if ($@) {
		print "Error: $@";
		status 'internal_server_error';
		return to_json( { message => 'Oops... Something went wrong!' } );
	}

	return to_json( { status => 'Ok' } );
};

# Display config
get '/config' => sub {
	my $jsonOptions = { pretty => 1, canonical => 1 };
	my $config      = to_json( config(), $jsonOptions );
	return template( 'config', { config => $config } );
};

# hook before => sub {
# 	my $currentPath = request->path;

# 	if ( !session('user') && $currentPath ne '/login' ) {
# 		my $returnUrl = request->uri;
# 		return redirect "/login?returnUrl=" . URI->new($returnUrl)->as_string;
# 	}

# 	if ( session('user') && $currentPath eq '/login' ) {
# 		return redirect "/";
# 	}
# };

true;
