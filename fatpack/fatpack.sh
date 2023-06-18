#!/bin/sh

PERL=${PERL:-perl}
FATPACK=${FATPACK:-fatpack}

die() {
    msg="$1\n"
    shift
    # shellcheck disable=SC2059
    printf "${msg}" "$@" 1>&2
    exit 1
}

use=$(
    for mod in \
        parent \
        Exporter \
        HTTP::Parser \
        HTTP::Tiny \
        Plack::App::Proxy \
        Plack::App::Proxy::Backend::HTTP::Tiny \
        Plack::Builder \
        Plack::Handler::Starlight \
        Plack::Handler::Thrall \
        Plack::Middleware::AccessLog \
        Plack::Middleware::Proxy::Requests \
        Plack::Middleware::Proxy::Connect::IO \
        Plack::Middleware::TrafficLog \
        Time::Local; do
        echo "--use=${mod}"
    done
)

delete=$(
    for mod in \
        Sub::Name \
        Time::TZOffset; do
        path=$(echo "${mod}" | sed 's,::,/,g')
        printf "%s" "next if m{^${path}\.pm$}; "
    done
)

# cpm install --reinstall if parent Exporter HTTP::Tiny

cd "$(dirname "$0")" || exit 0

rm -f fatpacker.trace packlists pureproxy
rm -rf fatlib

# shellcheck disable=SC2086
PLACK_HTTP_PARSER_PP=1 ${FATPACK} trace ${use} ../script/pureproxy.pl

${PERL} -pi -e "${delete}" fatpacker.trace

# shellcheck disable=SC2046
${FATPACK} packlists-for $(cat fatpacker.trace) >packlists

# shellcheck disable=SC2046
${FATPACK} tree $(cat packlists)

for mod in \
    if \
    parent \
    Clone::PP \
    Exporter \
    HTTP::Date \
    HTTP::Status \
    HTTP::Tiny \
    JSON::MaybeXS \
    Module::Load \
    Time::Local \
    Try::Tiny \
    URI \
    URI::Escape \
    WWW::Form::UrlEncoded \
    WWW::Form::UrlEncoded::PP \
    HTTP::Headers; do
    path=$(echo "${mod}" | sed 's,::,/,g')
    if [ ! -f "fatlib/${path}.pm" ]; then
        mkdir -p "fatlib/$(dirname "${path}")"
        cp -f "$(${PERL} -le "use ${mod} (); print \$INC{'${path}.pm'}")" "fatlib/${path}.pm" # "
        test -f "fatlib/${path}.pm" || die "Missing module at site_perl. Reinstall it with command:\ncpanm --reinstall %s" "${mod}"
    fi
done

rm -rf fatlib/auto/share
find fatlib \( -name .keep -o -name '*.bundle' -o -name '*.pod' \) -print0 | xargs -0r rm -f

${FATPACK} file ../script/pureproxy.pl >pureproxy

${PERL} -pi -e 's{^#!.*/perl$}{#!/usr/bin/env perl}' pureproxy
chmod +x pureproxy

${PERL} ./pureproxy -v
