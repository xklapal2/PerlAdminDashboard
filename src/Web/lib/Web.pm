package Web;

use strict;
use warnings;

# 3rd party
use Dancer2;
use Dancer2::Plugin::Database;
use URI;

# custom modules
use PasswordHasher qw/hashPassword verifyPassword/;
use EmailReader    qw/getEmails/;
use Constants;

our $VERSION = '0.1';

####################################################
###                    Endpoints                 ###
####################################################

get '/' => sub {
    template 'index' => { 'title' => 'Web' };
};

get '/hash' => sub {
    my $person = Person->new( name => 'Alice', age => 30 );
    print $person->describe();

    return hashPassword("secret");
};

# Home - Helpdesk
get '/a' => sub {
    my @requests;

    eval { @requests = [ database->quick_select( 'helpdeskRequests', {} ) ]; };

    if ($@) {
        error "Failed to load helpdesk requests from database: $@";

        # TODO: log $@
        return template 'error',
          { errorMsg => "Failed to load helpeds requests." };
    }

    if (@requests) {
        return 'index', { requests => \@requests };
    }

    return '<pre>No requests yet...</pre>';
};

# Login page
get '/login' => sub {
    my $returnUrl = query_parameters->get('returnUrl')
      || '/';    # Default return URL if none provided

    # Ensure the returnUrl is URI-encoded to handle special characters
    $returnUrl = URI->new($returnUrl)->as_string;

    template 'login', { returnUrl => $returnUrl };
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
    return
        '<pre>'
      . to_json( $config, { pretty => 1, canonical => 1 } )
      . '</pre>';
};

# Handle Fetch Emails
get '/api/fetchEmails' => sub {

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
                    state     => Constants::HelpdeskRequestStateNew
                }
            );

            push @emailsToRemove, $email->{messageId};
            print "mail inserted: $email->{subject} \n";
            debug "mail inserted: $email->{subject} \n";
        };

        if ($@) {
            error
"Failed to insert email to database: date: $email->{date}, sender: $email->{sender}";
        }
    }

    # TODO: Remove @emailsToRemove uisng IMAP

    my $emailsJson = to_json( \@emails, { pretty => 1, canonical => 1 } );

    status 200;

    # return 'ok';
    return '<pre>' . $emailsJson . '</pre>';
};

hook before => sub {
    my $currentPath = request->path;

    if ( !session('user') && $currentPath ne '/login' ) {
        my $returnUrl = request->uri;
        return redirect "/login?returnUrl=" . URI->new($returnUrl)->as_string;
    }

    if ( session('user') && $currentPath eq '/login' ) {
        return redirect "/";
    }
};

true;
