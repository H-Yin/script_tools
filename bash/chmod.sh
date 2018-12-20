#!/usr/bin/env bash

##################################################################
#  File        : chmod.sh
#  Author      : H.Yin
#  Email       : csustyinhao@gmail.com
#  Created     : 2018-11-01 11:34:39(+0800)
#  Modified    : 2018-12-20 15:01:49(+0800)
#  GitHub      : https://github.com/H-Yin/
#  Description : chmod for all script
#################################################################

files=`ls ./`
echo $files
for file in $files; do
    if [[ "$file" =~ \.sh && ! -x "$file" ]]; then
        chmod a+x $file
    fi
done
