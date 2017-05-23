#!/bin/bash

# transform-alignments.sh s3://source sample s3://dest
SRC_DIR = $1
SAMPLE = $2
DEST_DIR = $3
DRIVER_MEMORY = "58G"
EXECUTOR_MEMORY = "58G"
HDFS_DIR = "/data"
HDFS_PATH = "hdfs://spark-master:8020$HDFS_DIR"

echo "creating $HDFS_DIR directory on hdfs..."
hadoop fs -mkdir -p "$HDFS_DIR"

echo "downloading $SRC_DIR/$SAMPLE.bam to $HDFS_PATH/$SAMPLE.bam..."
spark-submit \
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

adam-shell -i extract-mhc.scala $HDFS_PATH/$SAMPLE.bam $HDFS_PATH/$SAMPLE.mhc.bam

echo "uploading $HDFS_PATH/$SAMPLE.mhc.bam to $DEST_DIR..."
spark-submit \
    conductor-0.5-SNAPSHOT/conductor-0.5-SNAPSHOT-distribution.jar \
    $HDFS_PATH/$SAMPLE.mhc.bam \
    $DEST_DIR/$SAMPLE.mhc.bam
