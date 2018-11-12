#!/usr/bin/bash

##################################################################
#  File        : export_data_from_hive.sh
#  Author      : H.Yin
#  Email       : csustyinhao@gmail.com
#  Created     : 2018-11-01 18:10:39(+0800)
#  Modified    : 2018-11-09 17:05:11(+0800)
#  GitHub      : https://github.com/H-Yin/script_tools
#  Description : export data from hive
#################################################################


DATABASE='db_recmd_tianyi_cre'
TEMPDIR=$(pwd)'/.temp'
OUTPUT='result.txt'
DELIMITER=','

if [[ $# -lt 1 ]]; then echo "Usage: ./export_data_from_hive.sh [OUTPUT]"; fi
if [[ -n $1 ]]; then OUTPUT=$1; fi

QUERY_SQL=$(cat <<-EOF
USE $DATABASE;

INSERT OVERWRITE LOCAL DIRECTORY '$TEMPDIR'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '$DELIMITER'
select bh_uuid, up_rankscore
  from dm_f_news_base_feature_hour
 where dt = '20181101'
   and hr = '18' and bh_rfunc=15 and up_rankscore > 0;

EOF
)

echo "SQL: " $QUERY_SQL

hive -e "$QUERY_SQL" >/dev/null 2>&1
exitcode=$?
if [[ $exitcode -ne 0 ]]; then
    echo "ERROR: hive excute sql failed."
    exit $exitcode
else
    cat $TEMPDIR/0* > $OUTPUT
    rm -rf $TEMPDIR
fi
