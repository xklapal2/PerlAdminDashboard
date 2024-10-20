package App;

use strict;
use warnings;

use Dancer2;
use Dancer2::Plugin::Database;
use URI;

# custom modules
use lib '.';
use Services::Crypto::PasswordHasher qw/hashPassword verifyPassword/;

####################################################
###                    Endpoints                 ###
####################################################

# Home - Helpdesk
get '/' => sub {
    return template 'index', {};
};

# Login page
get '/login' => sub {
    my $returnUrl = query_parameters->get('returnUrl') || '/';  # Default return URL if none provided

    # Ensure the returnUrl is URI-encoded to handle special characters
    $returnUrl = URI->new($returnUrl)->as_string;

    template 'login', { returnUrl => $returnUrl };
};

# Handle login
post '/login' => sub {
    my $username = body_parameters->get('username');
    my $password = body_parameters->get('password');
    my $returnUrl = body_parameters->get('returnUrl') || '/';  # Default return URL if none provided

    my $user = database->quick_select('users', { username => $username });

    if ($user && verifyPassword($user->{password}, $password)) {
        session user => $user->{username};
        return redirect $returnUrl;
    } else {
        return template 'login', { returnUrl => $returnUrl, loginFailed => 1 };
    }
};

get '/monitoring' => sub {
    return template 'monitoring', {};
};

get '/config' => sub {
    my $config = config();
    return '<pre>' . to_json($config, { pretty => 1, canonical => 1 }) . '</pre>';
};

hook before => sub {
    my $currentPath = request->path;

    if (!session('user') && $currentPath ne '/login') {
        my $returnUrl = request->uri;
        return redirect "/login?returnUrl=" . URI->new($returnUrl)->as_string;
    }

    if(session('user') && $currentPath eq '/login'){
        return redirect "/";
    }
};

App->to_app;
