HDFS=$1
OUTPUT='result.txt'
if [[ -z "$HDFS" ]]; then
    echo "ERROR : Invalid parameters."
    echo "Usage : ./$0 HDFS [OUTPUT]"
    exit 127
else
    OUTPUT=$2
    if [[ -n "$3" ]]; then OUTPUT=$3; fi
    > $OUTPUT
    echo "Start exporting data ..."
    files=`hadoop fs -ls $HDFS | awk '/^-r/{print $8}'`
    for file in $files; do
        hadoop fs -test -e $file
        if [ $? == 0 ]; then
            echo "Export data from $file ..."
            hadoop fs -cat $file >> $OUTPUT
        fi
    done
fi
