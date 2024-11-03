package MonitoringClientInfo;

use strict;
use warnings;

use HTML::Escape qw(escape_html);

sub new {
    my ( $class, %args ) = @_;

    my $self = {
        id        => $args{id}        || 0,
        hostname  => $args{hostname}  || '',
        version   => $args{version}   || '',
        uptime    => $args{uptime}    || '',
        tcpucount => $args{tcpucount} || 0,
        memtotal  => $args{memtotal}  || 0,
    };

    bless $self, $class; # bless explained in readme.md: OOP -> Classes -> Bless
    return $self;
}

# getters and setters
sub hostname {
    $_[0]->{hostname} = $_[1] if defined $_[1];
    $_[0]->{hostname};
}

sub version {
    $_[0]->{version} = $_[1] if defined $_[1];
    $_[0]->{version};
}

sub uptime {
    $_[0]->{uptime} = $_[1] if defined $_[1];
    $_[0]->{uptime};
}

sub tcpucount {
    $_[0]->{tcpucount} = $_[1] if defined $_[1];
    $_[0]->{tcpucount};
}

sub memtotal {
    $_[0]->{memtotal} = $_[1] if defined $_[1];
    $_[0]->{memtotal};
}

