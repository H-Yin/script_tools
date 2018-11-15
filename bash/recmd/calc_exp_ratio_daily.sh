#!/usr/bin/bash

##################################################################
#  File        : calc_exp_ratio_daily.sh
#  Author      : H.Yin
#  Email       : csustyinhao@gmail.com
#  Created     : 2018-11-09 16:28:01(+0800)
#  Modified    : 2018-11-09 17:54:46(+0800)
#  GitHub      : https://github.com/H-Yin/script_tools
#  Description : calculte exp_ratio on a daily timescale
#################################################################


DATABASE='db_recmd_tianyi_cre'
TEMPDIR_1='.temp_1'
TEMPDIR_2='.temp.2'
OUTPUT_1='each.exp.txt'
OUTPUT_2='total.exp.txt'
OUTPUT='result.txt'
DELIMITER=','

DAY=$1
if [[ -z $DAY ]]; then
    echo "ERROR : Invalid Parameter."
    echo "Usage : $0 DAY [OUTPUT]"
    exit 127
fi

if [[ -z $2 ]]; then OUTPUT=$2; fi

QUERY_EXP_SQL=$(cat <<-EOF
USE $DATABASE;

INSERT OVERWRITE LOCAL DIRECTORY '$TEMPDIR_1'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '$DELIMITER'
select tr, count(uuid)
  from ods_f_news_log_info
 where dt           = '$DAY'
   and rfunc        in (95, 96, 97, 98, 99)
   and code         = 'CL_R_1'
   and cre_mod      = 'tianyi_f'
   and play_duration is null
   and uuid is not null
   and did is not null
   and length(uuid) = 32
   and uuid not like 'ad_%'
   and uuid not like 'media_%'
 group by tr;


EOF
)

QUERY_TOTAL_SQL=$(cat <<-EOF
USE $DATABASE;

INSERT OVERWRITE LOCAL DIRECTORY '$TEMPDIR_2'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '$DELIMITER'
select count(uuid)
  from ods_f_news_log_info
 where dt           = '$DAY'
   and rfunc in (95, 96, 97, 98, 99)
   and code         = 'CL_R_1'
   and cre_mod      = 'tianyi_f'
   and play_duration is null
   and uuid is not null
   and did is not null
   and length(uuid) = 32
   and uuid not like 'ad_%'
   and uuid not like 'media_%'

EOF
)

hive -e "$QUERY_EXP_SQL"
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

awk -F, -v total=`cat $OUTPUT_2` '{printf("%d %d %10.6f%%\n", $1, $2, $2 / total * 100) }' $OUTPUT_1 | sort -gk 1 > $OUTPUT

