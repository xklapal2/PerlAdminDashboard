package App;

use strict;
use warnings;
use Dancer2;

# custom modules
use lib '.';
use Services::Crypto::PasswordHasher qw/hashPassword verifyPassword/;

# Home and Login page
get '/' => sub {
my $password = "secret";
my $hash = hashPassword($password);
print "Hashed Password: $hash\n";

my $isValid = verifyPassword($hash, $password);

    if ($isValid) {
        print "Password is valid\n";
    } else {
        print "Password is invalid\n";
    }

    template 'index', {
        isValid => $isValid,
        password => $password,
        hash => $hash
    };
};

get '/config' => sub {
    # $a = 10 /0;
    my $config = config();
    return '<pre>' . to_json($config, {pretty => 1, canonical => 1}) . '</pre>';
};

App->to_app;
