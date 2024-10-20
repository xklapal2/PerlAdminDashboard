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
    template 'index', {};
};

# Handle login
post '/login' => sub {
    my $username = body_parameters->get('username');
    my $password = body_parameters->get('password');

    my $user = database->quick_select('users', { username => $username });

    if ($user && verifyPassword($user->{password}, $password)) {
        session user => $user->{username};
        return redirect '/config';
    } else {
        return "Invalid username or password.";
    }
};

get '/config' => sub {
    my $config = config();
    return '<pre>' . to_json($config, {pretty => 1, canonical => 1}) . '</pre>';
};

App->to_app;
