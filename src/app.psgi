package App;

use strict;
use warnings;
use Dancer2;

use Dancer2::Plugin::Database;

# custom modules
use lib '.';
use Services::Crypto::PasswordHasher qw/hashPassword verifyPassword/;

####################################################
###                    Ednpoints                 ###
####################################################

# Home and Login page
get '/' => sub {
    my $returnUrl = query_parameters->get('returnUrl');

    if($returnUrl){
        $returnUrl = '?returnUrl=' . $returnUrl;
    }

    template 'index', {returnUrl => $returnUrl};
};

# Handle login
post '/login' => sub {
    my $username = body_parameters->get('username');
    my $password = body_parameters->get('password');

    my $user = database->quick_select('users', { username => $username });

    if ($user && verifyPassword($user->{password}, $password)) {
        session user => $user->{username};

        my $returnUrl = query_parameters->get('returnUrl');
        print "incomming returnUrl: $returnUrl\n";

        return redirect $returnUrl ? $returnUrl : '/config';
    } else {
        return "Invalid username or password.";
    }
};

get '/helpdesk' => sub {
    return template 'helpdesk' {};
};

get '/config' => sub {
    my $config = config();
    return '<pre>' . to_json($config, {pretty => 1, canonical => 1}) . '</pre>';
};

hook before => sub {
    my $currentPath = request->path;

    if (!session('user') && $currentPath ne '/' && $currentPath ne '/login') {
        return redirect "/?returnUrl=$currentPath";
    }
};

App->to_app;
