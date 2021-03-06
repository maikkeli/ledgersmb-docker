#!/bin/bash

update_ssmtp.sh
cd /srv/ledgersmb

if [[ ! -f ledgersmb.conf ]]; then
  cp conf/ledgersmb.conf.default ledgersmb.conf
  sed -i \
    -e "s/\(cache_templates = \).*\$/cache_templates = 1/g" \
    -e "s/\(host = \).*\$/\1$POSTGRES_HOST/g" \
    -e "s%\(sendmail   = \).*%\1/usr/bin/ssmtp%g" \
    /srv/ledgersmb/ledgersmb.conf
fi

if [ ! -z ${CREATE_DATABASE+x} ]; then
  perl tools/dbsetup.pl --company $CREATE_DATABASE \
  --host $POSTGRES_HOST \
  --postgres_password "$POSTGRES_PASS"
fi

# Needed for modules loaded by cpanm
export PERL5LIB
for PerlLib in /usr/lib/perl5* /usr/local/lib/perl5*/site_perl/* ; do
    [[ -d "$PerlLib" ]] && {
        PERL5LIB="$PerlLib";
        echo -e "\tmaybe: $PerlLib";
    }
done ;
echo "Selected PERL5LIB=$PERL5LIB";

# start ledgersmb
exec starman tools/starman.psgi
