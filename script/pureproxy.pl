#!/usr/bin/perl

=head1 NAME

pureproxy - a Pure Perl HTTP proxy server

=head1 SYNOPSIS

  pureproxy --port=5000 --workers=10

=cut

no warnings;

our $VERSION = '0.0100';

BEGIN {
    *warnings::import = sub { };
}

BEGIN {
    delete $ENV{http_proxy};
    delete $ENV{https_proxy};
}

use Plack::Builder;
use Plack::App::Proxy;

my $app = builder {
    enable 'AccessLog';
    enable 'Proxy::Connect::IO';
    enable 'Proxy::Requests';
    Plack::App::Proxy->new(backend => 'HTTP::Tiny')->to_app;
};

use Plack::Runner;

use Starlight;
use Plack;

sub version {
    print "PureProxy/$VERSION Starlight/", Starlight->VERSION, " Plack/", Plack->VERSION, " Perl/$]\n";
}

my $runner = Plack::Runner->new(
    server     => 'Starlight',
    env        => 'proxy',
    loader     => 'Delayed',
    version_cb => \&version,
);

$runner->parse_options('--server-software', "PureProxy/$VERSION", @ARGV);

$runner->run;#($app);
