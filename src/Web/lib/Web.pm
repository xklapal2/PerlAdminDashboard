package Web;

use strict;
use warnings;

# 3rd party
use Dancer2;
use Dancer2::Plugin::Database;
use URI;
use Data::Dumper;    # For debugging

# custom modules
use Entities::HelpdeskRequest;
use PasswordHasher qw/hashPassword verifyPassword/;
use EmailReader    qw/getEmails/;
use Constants qw(%helpdeskRequestStates $HelpdeskRequestStateNew getStateLabel);

our $VERSION = '0.1';

####################################################
###                    Endpoints                 ###
####################################################

# Home - Helpdesk
get '/' => sub {
    my @requests;
    eval {
        my @requestsDictionaries =
          database->quick_select( 'helpdeskRequests', {} );
        @requests = map { Entities::HelpdeskRequest->fromDictionary($_) }
          @requestsDictionaries;
    };

    # print Dumper(@requests);
    if ($@) {
        error "Failed to load helpdesk requests from database: $@";

        # TODO: log $@
        return template 'error',
          { errorMsg => "Failed to load helpeds requests." };
    }

    my $length = @requests;

    return template 'index' => {
        'title'          => 'Helpdesk',
        'requests'       => @requests ? \@requests : [],
        'helpdeskStates' => \%helpdeskRequestStates,
    };
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

            push @emailsToRemove, $email->{messageId};
            debug "mail inserted: $email->{subject} \n";
        };

        if ($@) {
            error
"Failed to insert email to database: date: $email->{date}, sender: $email->{sender}";
        }
    }

    # TODO: Remove @emailsToRemove uisng IMAP

    my $emailsJson = to_json( \@emails, { pretty => 1, canonical => 1 } );

    return redirect '/';
};

post '/updateProgress' => sub {
    my $data        = from_json( request->body );
    my $id          = $data->{id};
    my $newProgress = $data->{newProgress};

    if ( !getStateLabel($newProgress) ) {
        status 'bad_request';
        return to_json { message => 'Invalid progress!' };
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
        return to_json { message => 'Oops... Something went wrong!' };
    }

    return to_json { status => 'Saved successfully.' };
};

# Login page
get '/login' => sub {
    my $returnUrl = query_parameters->get('returnUrl')
      || '/';    # Default return URL if none provided

    # Ensure the returnUrl is URI-encoded to handle special characters
    $returnUrl = URI->new($returnUrl)->as_string;

    return template 'login', { returnUrl => $returnUrl };
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
        return redirect $returnUrl;
    }
    else {
        return template 'login', { returnUrl => $returnUrl, loginFailed => 1 };
    }
};

get '/monitoring' => sub {
    return template 'monitoring', {};
};

# Display config
get '/config' => sub {
    my $config = config();
    return template 'config',
      { config => to_json( $config, { pretty => 1, canonical => 1 } ) };
};

# hook before => sub {
#     my $currentPath = request->path;

#     if ( !session('user') && $currentPath ne '/login' ) {
#         my $returnUrl = request->uri;
#         return redirect "/login?returnUrl=" . URI->new($returnUrl)->as_string;
#     }

#     if ( session('user') && $currentPath eq '/login' ) {
#         return redirect "/";
#     }
# };

true;
