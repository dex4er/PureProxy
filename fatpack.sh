#!/bin/sh

die () {
    msg="$1\n"
    shift
    printf "$msg" "$@" 1>&2
    exit 1
}

use=`
    for mod in \
        parent \
        Exporter \
        HTTP::Parser \
        HTTP::Tiny \
        Plack::App::Proxy \
        Plack::App::Proxy::Backend::HTTP::Tiny \
        Plack::Handler::Starlight \
        Plack::Middleware::AccessLog \
        Plack::Middleware::Proxy::Requests \
        Plack::Middleware::Proxy::Connect::IO \
    ; do
        echo "--use=$mod"
    done
`

delete=`
    for mod in \
        Sub::Name \
    ; do
        path=$(echo "$mod" | sed 's,::,/,g')
        printf "\,^$path\.pm$,d; "
    done
`

# cpanm --reinstall parent Exporter HTTP::Tiny

rm -f fatpacker.trace packlist pureproxy
rm -rf fatlib

PLACK_HTTP_PARSER_PP=1 fatpack trace $use script/pureproxy.pl

sed -i "$delete" fatpacker.trace

fatpack packlists-for `cat fatpacker.trace` >packlists

fatpack tree `cat packlists`

for mod in \
    parent \
    Exporter \
    HTTP::Tiny \
; do
    path=$(echo "$mod" | sed 's,::,/,g')
    test -f fatlib/$path.pm || die "Missing module at site_perl. Reinstall it with command:\ncpanm --reinstall %s" $mod
done

rm -rf fatlib/auto/share

fatpack file script/pureproxy.pl > pureproxy

sed -i 's,^#!.*/perl$,#!/usr/bin/env perl,' pureproxy
chmod +x pureproxy
