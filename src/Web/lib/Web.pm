package Web;
use Dancer2;

use PasswordHasher qw/hashPassword verifyPassword/;

our $VERSION = '0.1';

get '/' => sub {
    template 'index' => { 'title' => 'Web' };
};

get '/hash' => sub {
    return hashPassword("secret");
};

true;
