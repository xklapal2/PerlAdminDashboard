use strict;
use warnings;
use Dancer2;

# Home page
get '/' => sub {
    template 'index';
};

start;
