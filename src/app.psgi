use strict;
use warnings;
use Dancer2;

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

start;
