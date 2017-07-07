#!/bin/bash -x
echo "Starting kafka-monitor"
exec java -cp /opt/kafka-monitor/KafkaOffsetMonitor-assembly-0.2.1.jar com.quantifind.kafka.offsetapp.OffsetGetterWeb --zk ${ZK_CONNECTION} --port ${MONITOR_PORT:-8080} --refresh ${REFRESH_SECONDS}.seconds --retain ${RETAIN_DAYS}.days --dbName /opt/kafka-monitor/db/monitor 
