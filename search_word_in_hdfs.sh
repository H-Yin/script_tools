#!/usr/bin/bash

##################################################################
#  File        : search_word_in_hdfs.sh
#  Author      : H.Yin
#  Email       : csustyinhao@gmail.com
#  Created     : 2018-10-30 15:39:06(+0800)
#  Modified    : 2018-11-01 17:08:36(+0800)
# GitHub       : https://github.com/H-Yin/script_tools.git
#  Description : regex search word in hdfs
#################################################################


HDFS=$1
WORD=$2
OUTPUT="result.txt"

if [[ -z "$HDFS" || -z "$WORD" ]]; then
    echo 'Usage: ./search_word_in_hdfs.sh HDFS_DIR WORD [OUTPUT]'
else
    if [[ -n "$3" ]]; then OUTPUT=$3; fi
    > $OUTPUT
    echo "Start search $WORD!"
    files=`hadoop fs -ls $HDFS* | awk '{print $8}' | grep '^/'`
    for file in $files; do
        hadoop fs -test -e $file
        if [ $? == 0 ]; then
            echo "search in $file ..."
            hadoop fs -cat $file | grep -nE "$WORD" >> $OUTPUT
        fi
    done
fi
