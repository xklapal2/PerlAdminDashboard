package Web;

use strict;
use warnings;

# 3rd party
use Dancer2;
use Dancer2::Plugin::Database;
use URI;
use Data::Dumper;    # For debugging
use Time::Piece;

use Plack::App::WebSocket;

# custom modules
use Entities::HelpdeskRequest;
use Entities::MonitoringClientInfo;
use PasswordHasher ("hashPassword", "verifyPassword");
use EmailReader    ("getEmails");
use DateTimeHelper ("formatDate");
use Constants ('%helpdeskRequestStates', '$HelpdeskRequestStateNew', 'getStateLabel');

our $VERSION = '0.1';

####################################################
###                    Endpoints                 ###
####################################################

# Home - Helpdesk
get '/' => sub {
	my @requests;
	eval {
		my @requestsDictionaries = database->quick_select( 'helpdeskRequests', {} );
		@requests = map (Entities::HelpdeskRequest->new(%$_), @requestsDictionaries);
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
		print request->body;

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

post '/monitoring/resources/:hostname' => sub {
	my $hostname = route_parameters->get('hostname');

	eval {
		my $client = database->quick_select( 'monitoringClients',{ hostname => $hostname } );

		if (!$client) {
			return; # I don't want to accept unknown client's requests
		}
		my $resources = decode_json( request->body );
		print "$resources->{cpuTotal}\n";
		print "$resources->{timestamp}\n";

		database->quick_insert(
			'monitoringStatus',
			{
				hostname           => $client->{hostname},
				timestamp             => $resources->{timestamp},
				cpu            => $resources->{cpuTotal}
			}
		);
	};

	if ($@) {
		print "Error during processing monitoring/resources/$hostname: $@";
		status 'internal_server_error';
		return to_json( { message => 'Oops... Something went wrong!' } );
	}

	return to_json( { status => 'Ok' } );
};

get '/client/detail/:hostname' => sub {
	my $hostname = route_parameters->get('hostname');

	return template(
		'clientDetail',
		{
			'hostname' => $hostname,
			'wsUrl' => "ws://localhost:5000/ws/$hostname"
		}
	);
};

get '/client/status/:hostname' => sub {
	my $hostname = route_parameters->get('hostname');

	my @statusRecords;
	eval {
		my $results = database->quick_select(
			'monitoringStatus',
			{ hostname => $hostname },
			{
				order_by => { -desc => 'timestamp' },
				limit    => 20
			}
		);

		@statusRecords = map { Entities::MonitoringStatus->new(%$_) } @results;
	};

	if ($@) {
		print "Error: $@";
		status 'internal_server_error';
		return to_json( { message => 'Oops... Something went wrong!' } );
	}

	return @statusRecords;
  }

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


####################################################
###                   WebSockets                 ###
####################################################

# my %producers = ();
# my %subscribers = ();

# WebSocket endpoint for subscribers
# get '/ws/:producer' => sub {
# 	my $producer = route_parameters->get('producer');
# 	my $env = request->env;

# 	# Log to check when a WebSocket connection is attempted
# 	warn "New WebSocket connection attempt for producer: $producer\n";

# 	# Initialize WebSocket
# 	Plack::App::WebSocket->new(
# 		on_establish => sub {
# 			my $ws = shift;

# 			# Store WebSocket connection in subscribers hash
# 			eval{push (@{ $subscribers{$producer} }, $ws);};

# 			if($@){
# 				warn "Error while connection to WS subscriber: $@\n";
# 			}

# 			# Send a welcome message to the client (optional)
# 			# $ws->send("You are now subscribed to producer: $producer");

# 			# Log when the connection is open
# 			warn "WebSocket connection open for producer: $producer\n";

# 			# Handle incoming messages (optional)
# 			$ws->on(
# 				message => sub {
# 					my ($message) = @_;
# 					warn "Received message: $message\n";
# 				}
# 			);

# 			# Clean up connection when it's finished (closed)
# 			$ws->on(
# 				finish => sub {
# 					@{ $subscribers{$producer} } = grep { $_ != $ws } @{ $subscribers{$producer} };
# 					warn "WebSocket connection closed for producer: $producer\n";
# 				}
# 			);
# 		}
# 	)->call($env);
# };


# get '/wstest' => sub {
# 	my $env = request->env;
# 	print "Reached /wstest endpoint\n";

# 	Plack::App::WebSocket->new(
# 		on_establish => sub {
# 			print "WebSocket established\n";
# 			my ($ws, $psgi_env, @handshake_results) = @_;
# 			print "WebSocket handshake completed. Handshake results: " . Dumper(\@handshake_results) . "\n";
# 		},
# 		on_error => sub {
# 			eval{
# 				print "WebSocket error occurred\n";
# 				my ($env, $error) = @_;
# 				print Dumper(@_);
# 				print "WebSocket error occurred: ", (defined $error ? $error : 'Unknown error'), "\n";
# 			};
# 			if($@){
# 				warn "Error on error: $@\n";
# 			}
# 		}
# 	)->call($env);
# };

true;