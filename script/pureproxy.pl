#!/usr/bin/perl

=head1 NAME

pureproxy - a Pure Perl HTTP proxy server

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

if ($runner->{help}) {
    require Pod::Usage;
    Pod::Usage::pod2usage(-verbose => 1, -input => \*DATA);
}

my %options = @{$runner->{options}};

if ($options{traffic_log}) {
    $body_eol = $options{traffic_log_body_eol};
    if ($options{traffic_log} ne '1') {
        open my $logfh, ">>", $options{traffic_log}
            or die "open($options{traffic_log}): $!";
        $logfh->autoflush(1);
        $app = builder { enable 'TrafficLog', logger => sub { $logfh->print( @_ ) }, body_eol => $body_eol; $app; };
    } else {
        $app = builder { enable 'TrafficLog', body_eol => $body_eol; $app; };
    }
}

if (not exists $options{access_log}) {
    $app = builder { enable 'AccessLog'; $app; };
}

$runner->run($app);

__DATA__

=head1 SYNOPSIS

  pureproxy --port=5000 --workers=10

=head1 DESCRIPTION

This is pure-Perl proxy HTTP server which can be run on almost every Perl
installation.

=cut

__END__

=head1 SEE ALSO

L<http://github.com/dex4er/PureProxy>.

=head1 BUGS

This tool has unstable features and can change in future.

=head1 AUTHOR

Piotr Roszatycki <dexter@cpan.org>

=head1 LICENSE

Copyright (c) 2014 Piotr Roszatycki <dexter@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as perl itself.

See L<http://dev.perl.org/licenses/artistic.html>
