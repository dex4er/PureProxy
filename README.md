# PureProxy

[![CI](https://github.com/dex4er/PureProxy/actions/workflows/ci.yaml/badge.svg)](https://github.com/dex4er/PureProxy/actions/workflows/ci.yaml)
[![Trunk Check](https://github.com/dex4er/PureProxy/actions/workflows/trunk.yaml/badge.svg)](https://github.com/dex4er/PureProxy/actions/workflows/trunk.yaml)
[![CPAN](https://img.shields.io/cpan/v/App-PureProxy)](https://metacpan.org/dist/App-PureProxy)

## NAME

pureproxy - Pure Perl HTTP proxy server

## SYNOPSIS

```sh

    pureproxy --host=0.0.0.0 --port=5000 --workers=10 --server Starlight

    pureproxy --traffic-log=traffic.log --traffic-log-body-eol='|'

    pureproxy --access-log=access.log

    pureproxy --other-plackup-options

    pureproxy -v

    http_proxy=http://localhost:5000/ lwp-request -m get http://www.perl.org/

    https_proxy=http://localhost:5000/ lwp-request -m get https://metacpan.org/

```

## DESCRIPTION

This is pure-Perl HTTP proxy server which can be run on almost every Perl
installation.

It supports SSL and TLS if [IO::Socket::SSL](https://metacpan.org/pod/IO%3A%3ASocket%3A%3ASSL) is installed and IPv6 if
[IO::Socket::IP](https://metacpan.org/pod/IO%3A%3ASocket%3A%3AIP) is installed.

It can be fat-packed and then run with any system with standard Perl
interpreter without installing other packages. See `examples` directory
for fat-packed version of PureProxy script.

## ENVIRONMENT

## PUREPROXY\_SERVER

Changes the default PSGI server. This is [Thrall](https://metacpan.org/pod/Thrall) if Perl supports threads
and [Starlight](https://metacpan.org/pod/Starlight) otherwise.

## INSTALLATION

## With cpanm(1)

```sh

    cpanm App::PureProxy

```

## Directly

```sh

    lwp-request -m get https://raw.githubusercontent.com/dex4er/PureProxy/master/fatpack/install.sh | sh

```

or

```sh

    curl -qsSL https://raw.githubusercontent.com/dex4er/PureProxy/master/fatpack/install.sh | sh

```

or

```sh

    wget --quiet -O- https://raw.githubusercontent.com/dex4er/PureProxy/master/fatpack/install.sh | sh

```

## SEE ALSO

[http://github.com/dex4er/PureProxy](http://github.com/dex4er/PureProxy).

## BUGS

This tool has unstable features and can change in future.

## AUTHOR

Piotr Roszatycki <dexter@cpan.org>

## LICENSE

Copyright (c) 2014-2015, 2023 Piotr Roszatycki <dexter@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as perl itself.

See [http://dev.perl.org/licenses/artistic.html](http://dev.perl.org/licenses/artistic.html)
