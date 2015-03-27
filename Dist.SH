#!/bin/sh

set -e

PERL=${PERL:-perl}

test -x Build && ./Build distclean

rm -f examples/fatpacker.trace examples/packlists
rm -rf examples/fatlib

$PERL Build.PL

rm -f MANIFEST
: > README.md
if [ -f .travis.yml ]; then
    grep 'Build Status' .travis.yml | sed 's/^# //; s/.$/&\n/' > README.md
fi
$PERL -MPod::Markdown -e '$p=Pod::Markdown->new;$p->parse_from_filehandle(\*STDIN);print $p->as_markdown' \
    < script/pureproxy.pl \
    | $PERL -pe 'sub a { $_[0]=~tr/ /-/; $_[0] } s,[(]http://search.cpan.org/perldoc[?]([^#)]*)(#[^)]*)?[)],a("(http://metacpan.org/module/$1$2)"),eg' \
    >> README.md

$PERL Build manifest

$PERL Build distdir
diff -u -I^SIGNATURE MANIFEST *-[0-9]*.[0-9]*/MANIFEST

cd *-[0-9]*.[0-9]*

$PERL Build.PL
$PERL Build
$PERL Build test
$PERL -MApp::Prove -e '$a=App::Prove->new;$a->process_args(qw(-Iblib/arch -Iblib/lib xt));exit($a->run ? 0 : 1)'

if [ "$1" = sign ]; then
    $PERL Build distsign
    diff -u -I^SIGNATURE MANIFEST *-[0-9]*.[0-9]*/MANIFEST
else
    $PERL Build distdir
fi

chmod -R u+w,go-w *-[0-9]*.[0-9]*
tar zcf $(basename $(pwd)).tar.gz *-[0-9]*.[0-9]*

mv *.tar.gz ..
