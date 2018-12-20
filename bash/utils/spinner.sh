#!/bin/bash

##################################################################
#  File        : spinner.sh
#  Author      : H.Yin
#  Email       : csustyinhao@gmail.com
#  Created     : 2018-12-20 10:27:14(+0800)
#  Modified    : 2018-12-20 14:50:56(+0800)
#  GitHub      : https://github.com/H-Yin/
#  Description : 
#################################################################

sp='/-\|'
sc=0
# synchronous spinner
function spin_sync(){
    printf "\b${sp:sc++:1}"
    sc=$((sc % 4))
    sleep 0.2
}

printf "sync-spinner :  "
a=1
until [[ $a == 10 ]]; do
    spin_sync
    sleep 0.05
    a=$((a + 1))
done

# asynchronous spinner
function spin_asyn_start(){
    local sp='/-\|'
    local sc=0
    while [[ 1 ]]; do
        printf "\b${sp:sc++:1}"
        sc=$((sc % 4))
        sleep 0.2
    done
}
function spin_asyn_stop(){
    kill $1
}

printf "\nasyn-spinner :  "
a=1
# start spinner and run in the backgroud
spin_asyn_start &
# get the pid of spinner
spid=$!

until [[ $a == 10 ]]; do
    sleep 0.5
    a=$((a + 1))
done
# kill the spinner
spin_asyn_stop $spid

echo ""
