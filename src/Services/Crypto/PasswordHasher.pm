package Services::Crypto::PasswordHasher;

use strict;
use warnings;
use Exporter 'import'; # Import the Exporter module
use Crypt::Argon2 qw/argon2id_pass argon2_verify/;

our @EXPORT_OK = qw(hashPassword verifyPassword); # Functions to export

sub hashPassword {
    my ($password) = @_;
    my $salt = 'nqWVGBHSCGgdqTK6gRkRKA==';
    my $timeCost = 3;
    my $memoryCost = '32M';
    my $parallelism = 1;
    my $tagSize = 16;
    my $hashedPassword = argon2id_pass($password, $salt, $timeCost, $memoryCost, $parallelism, $tagSize); # Params: https://metacpan.org/pod/Crypt::Argon2#argon2_pass($type,-$password,-$salt,-$t_cost,-$m_factor,-$parallelism,-$tag_size)
    return $hashedPassword;
}

sub verifyPassword {
    my ($hashedPassword, $password) = @_;
    return argon2_verify($hashedPassword, $password);
}

1;
