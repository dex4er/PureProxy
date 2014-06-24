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

use constant SERVER => $ENV{PUREPROXY_SERVER} || $^O =~ /MSWin32|cygwin/ ? 'Thrall' : 'Starlight';

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

use Plack;
use Plack::Runner;

use if SERVER eq 'Thrall', 'Thrall';
use if SERVER eq 'Starlight', 'Starlight';

sub version {
    print "PureProxy/$VERSION ", SERVER, "/", SERVER->VERSION, " Plack/", Plack->VERSION, " Perl/$]\n";
}

my $runner = Plack::Runner->new(
    server     => SERVER,
    env        => 'proxy',
    loader     => 'Delayed',
    version_cb => \&version,
);

$runner->parse_options('--server-software', "PureProxy/$VERSION", @ARGV);

$runner->run($app);
