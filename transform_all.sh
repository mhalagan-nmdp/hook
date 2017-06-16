#!/bin/bash

# transform_all.sh bamids.txt

ids=$1
DRIVER_MEMORY="58G"
EXECUTOR_MEMORY="58G"
HDFS_DIR="/data"
HDFS_PATH="hdfs://spark-master:8020$HDFS_DIR"

SRC_DIR=s3://nmdp-human-longevity-data/data/raw
DEST_DIR=s3://nmdp-human-longevity-data/modified/mhc


for SAMPLE in `cat $ids`;do

    echo "creating $HDFS_DIR directory on hdfs..."
    hadoop fs -mkdir -p "$HDFS_DIR"

    echo "downloading $SRC_DIR/$SAMPLE.bam to $HDFS_PATH/$SAMPLE.bam..."
    spark-submit \
        --executor-memory 60G \
        conductor-0.5-SNAPSHOT/conductor-0.5-SNAPSHOT-distribution.jar \
        $SRC_DIR/$SAMPLE.bam \
        $HDFS_PATH/$SAMPLE.bam \
        --concat

    echo "downloading $SRC_DIR/$SAMPLE.bam.bai to $HDFS_PATH/$SAMPLE.bam..."
    spark-submit \
        conductor-0.5-SNAPSHOT/conductor-0.5-SNAPSHOT-distribution.jar \
        $SRC_DIR/$SAMPLE.bam.bai \
        $HDFS_PATH/$SAMPLE.bam.bai \
        --concat

    export BAMFILE=$HDFS_PATH/$SAMPLE.bam
    export BAMOUT=$HDFS_PATH/$SAMPLE.mhc.bam
    adam-shell -i extract-mhc.scala

    echo "uploading $HDFS_PATH/$SAMPLE.mhc.bam to $DEST_DIR..."
    spark-submit \
        --executor-memory 60G \
        conductor-0.5-SNAPSHOT/conductor-0.5-SNAPSHOT-distribution.jar \
        $HDFS_PATH/$SAMPLE.mhc.bam \
        $DEST_DIR/$SAMPLE.mhc.bam \
        --concat

    hdfs dfs -rm -r -f hdfs://spark-master:8020/data

done