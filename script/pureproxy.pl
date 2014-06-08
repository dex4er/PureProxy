#!/usr/bin/perl

no warnings;

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
my $runner = Plack::Runner->new;
$runner->parse_options(qw(-s Starlight -E proxy), @ARGV);
$runner->run($app);
