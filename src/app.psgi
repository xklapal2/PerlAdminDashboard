package App;

use strict;
use warnings;
use Dancer2;

# custom modules
use lib '.';
use Services::Crypto::PasswordHasher qw/hashPassword verifyPassword/;

set show_stacktrace => $ENV{DANCER_ENVIRONMENT}; # enables showing stack_trace in InternalServerError responses

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

App->to_app;
