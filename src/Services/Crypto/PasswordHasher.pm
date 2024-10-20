package Services::Crypto::PasswordHasher;

use strict;
use warnings;
use Exporter 'import'; # Import the Exporter module
use Crypt::Argon2 qw/argon2id_pass argon2_verify/;
use Crypt::URandom qw/urandom/;
use MIME::Base64 qw/encode_base64/;

our @EXPORT_OK = qw(hashPassword verifyPassword); # Functions to export

sub generateSalt {
    my $length = shift || 16; # Optinal parameter may be passed into generateSalt subroutine or default salt length to 16 bytes
    my $randomBytes = urandom($length);
    return encode_base64($randomBytes, '');
}

# subroutine returns both, hash and salt
sub hashPassword {
    my ($password) = @_;
    my $salt = generateSalt();
    my $timeCost = 3;
    my $memoryCost = '32M';
    my $parallelism = 1;
    my $tagSize = 16;

    # Params: https://metacpan.org/pod/Crypt::Argon2#argon2_pass($type,-$password,-$salt,-$t_cost,-$m_factor,-$parallelism,-$tag_size)
    my $hashedPassword = argon2id_pass($password, $salt, $timeCost, $memoryCost, $parallelism, $tagSize);

    return $hashedPassword;
}

sub verifyPassword {
    my ($hashedPassword, $password) = @_;
    return argon2_verify($hashedPassword, $password);
}

1;
