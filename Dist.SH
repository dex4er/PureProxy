#!/usr/bin/env bash

set -e

PERL=${PERL:-perl}
PROVE=${PROVE:-prove}

test -x Build && ./Build distclean

${PERL} Build.PL

rm -f MANIFEST

${PERL} -ni -e 'print unless /^##? NAME/ .. eof' README.md
dist_version_from=$(${PERL} -ne 'print if /dist_version_from/' Build.PL | ${PERL} -pe "s%.*=> '%%; s%',%%")
${PERL} -MPod::Markdown -e '$p=Pod::Markdown->new;$p->parse_from_filehandle(\*STDIN);print $p->as_markdown' \
    <"${dist_version_from:-lib/$(${PERL} -ne 'next unless /^name: /; s/^name: //; s,-,/,g; s/$/.pm/; print' META.yml)}" |
    ${PERL} -pe 'sub a { $_[0]=~tr/ /-/; $_[0] } s,[(]http://search.cpan.org/perldoc[?]([^#)]*)(#[^)]*)?[)],a("(http://metacpan.org/module/$1$2)"),eg' |
    ${PERL} -pe 's/^# /## /' \
        >>README.md

${PERL} Build manifest

${PERL} Build distdir
diff -u -I^SIGNATURE MANIFEST ./*-[0-9]*.[0-9]*/MANIFEST

cd ./*-[0-9]*.[0-9]*

${PERL} Build.PL
${PERL} Build

${PROVE} -Iblib/lib t

if [[ -z ${TEST_SKIP_EXTRA} ]] || [[ ${TEST_SKIP_EXTRA} == 0 ]]; then
    ${PROVE} -Iblib/lib xt
elif [[ -n ${TEST_SKIP_EXTRA} ]] && [[ ${TEST_SKIP_EXTRA} != 1 ]]; then
    # shellcheck disable=SC2046
    ${PROVE} -Iblib/lib $(find xt -name '*.t' ! -name "${TEST_SKIP_EXTRA}")
fi

if [[ $1 == sign ]]; then
    ${PERL} Build distsign
    diff -u -I^SIGNATURE MANIFEST ./*-[0-9]*.[0-9]*/MANIFEST
else
    ${PERL} Build distdir
fi

chmod -R u+w,go-w ./*-[0-9]*.[0-9]*

export COPYFILE_DISABLE=true
tar zcf "$(basename "$(pwd)").tar.gz" ./*-[0-9]*.[0-9]*

mv ./*.tar.gz ..
