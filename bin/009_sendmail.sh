#!/bin/bash
set -e
source conf/token.sh

save_list=($(ls -1 mail/*)) || exit 0
for f in "${save_list[@]}"; do
    cat $f | /usr/sbin/sendmail -i -f $MAIL_FROM $MAIL_TO
    rm $f
done
