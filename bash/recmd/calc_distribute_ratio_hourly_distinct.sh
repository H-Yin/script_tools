#!/bin/bash

##################################################################
#  File        : 
#  Author      : H.Yin
#  Email       : csustyinhao@gmail.com
#  Created     : 2018-11-09 16:28:01(+0800)
#  Modified    : 2018-11-09 17:54:46(+0800)
#  GitHub      : https://github.com/H-Yin/script_tools
#  Description : calculte dis_ratio on a hourly timescale
#################################################################

RFUNC=$1
if [[ -z $RFUNC ]]; then
    echo "ERROR : Invalid Parameter."
    echo "Usage : $0 RFUNC [OUTPUT]"
    exit 127
fi

DATABASE='db_recmd_tianyi_cre'
NOW=$(date -d 'now' +%s%N)
TEMPDIR_1="$NOW.dis_temp_1"
TEMPDIR_2="$NOW.dis_temp.2"
OUTPUT_1="$NOW.each.dis.txt"
OUTPUT_2="$NOW.total.dis.txt"
OUTPUT="$RFUNC_dis_ratio_dis.txt"
DELIMITER=','


if [[ -n $2 ]]; then OUTPUT=$2; fi

QUERY_DIS_SQL=$(cat <<-EOF
USE $DATABASE;

INSERT OVERWRITE LOCAL DIRECTORY '$TEMPDIR_1'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '$DELIMITER'
select bh_tr, count(distinct(bh_uuid))
  from dm_f_news_base_feature_hour
 where dt = '20181115'
   and (hr>='10' and hr<'15')
   and bh_rfunc        = '$RFUNC'
   and bh_cre_mod      = 'tianyi_f'
   and bh_play_duration is null
   and bh_uuid is not null
   and bh_did is not null
   and length(bh_uuid) = 32
   and bh_uuid not like 'ad_%'
   and bh_uuid not like 'media_%'
 group by bh_tr;

EOF
)

QUERY_TOTAL_SQL=$(cat <<-EOF
USE $DATABASE;

INSERT OVERWRITE LOCAL DIRECTORY '$TEMPDIR_2'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '$DELIMITER'
select count(distinct(bh_uuid))
  from dm_f_news_base_feature_hour
 where dt = '20181115'
   and (hr>='10' and hr<'15')
   and bh_rfunc        = '$RFUNC'
   and bh_cre_mod      = 'tianyi_f'
   and bh_play_duration is null
   and bh_uuid is not null
   and bh_did is not null
   and length(bh_uuid) = 32
   and bh_uuid not like 'ad_%'
   and bh_uuid not like 'media_%';

EOF
)

hive -e "$QUERY_DIS_SQL"
exitcode=$?
if [[ $exitcode -ne 0 ]]; then
    echo "ERROR : hive excute sql-1 failed."
    exit $exitcode
else
    cat $TEMPDIR_1/0* > $OUTPUT_1
    rm -rf $TEMPDIR_1
fi


hive -e "$QUERY_TOTAL_SQL"
exitcode=$?
if [[ $exitcode -ne 0 ]]; then
    echo "ERROR : hive excute sql-2 failed."
    exit $exitcode
else
    cat $TEMPDIR_2/0* > $OUTPUT_2
    rm -rf $TEMPDIR_2
fi
cat $OUTPUT_1
echo "total dis_num: "$(cat $OUTPUT_2) > $OUTPUT
echo -e "tr\tdis_num\tdis_ration" >> $OUTPUT
awk -F, -v total=`cat $OUTPUT_2` '{printf("%d\t%d\t%10.6f%%\n", $1, $2, $2 / total * 100) }' $OUTPUT_1 | sort -gk 1 >> $OUTPUT
