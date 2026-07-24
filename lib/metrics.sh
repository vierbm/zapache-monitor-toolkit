#!/usr/bin/env bash
#
# metrics.sh
#
# Apache Metrics Library
#
# Project : zapache-monitor-toolkit
# Version : 2.0.0-alpha
#

#
# Requires:
#
# source lib/apache.sh
#

#
# Generic metric lookup
#
metrics_get() {

    local metric="$1"

    apache_metric "$metric"
}

#
# Standard Apache metrics
#

metrics_total_accesses() {
    metrics_get "Total Accesses"
}

metrics_total_kbytes() {
    metrics_get "Total kBytes"
}

metrics_cpu_load() {
    metrics_get "CPULoad"
}

metrics_uptime() {
    metrics_get "Uptime"
}

metrics_req_per_sec() {
    metrics_get "ReqPerSec"
}

metrics_bytes_per_sec() {
    metrics_get "BytesPerSec"
}

metrics_bytes_per_req() {
    metrics_get "BytesPerReq"
}

metrics_busy_workers() {
    metrics_get "BusyWorkers"
}

metrics_idle_workers() {
    metrics_get "IdleWorkers"
}

metrics_connections_total() {
    metrics_get "ConnsTotal"
}

metrics_connections_writing() {
    metrics_get "ConnsAsyncWriting"
}

metrics_connections_keepalive() {
    metrics_get "ConnsAsyncKeepAlive"
}

metrics_connections_closing() {
    metrics_get "ConnsAsyncClosing"
}

#
# Numeric validation
#

metrics_is_numeric() {

    [[ "$1" =~ ^[0-9]+([.][0-9]+)?$ ]]
}

#
# Print all metrics
#

metrics_dump() {

    cat <<EOF
Total Accesses      : $(metrics_total_accesses)
Total kBytes        : $(metrics_total_kbytes)
CPULoad             : $(metrics_cpu_load)
Uptime              : $(metrics_uptime)
ReqPerSec           : $(metrics_req_per_sec)
BytesPerSec         : $(metrics_bytes_per_sec)
BytesPerReq         : $(metrics_bytes_per_req)
BusyWorkers         : $(metrics_busy_workers)
IdleWorkers         : $(metrics_idle_workers)
ConnsTotal          : $(metrics_connections_total)
ConnsAsyncWriting   : $(metrics_connections_writing)
ConnsAsyncKeepAlive : $(metrics_connections_keepalive)
ConnsAsyncClosing   : $(metrics_connections_closing)
EOF
}

#
# Export metrics as KEY=VALUE
#

metrics_export() {

    echo "TotalAccesses=$(metrics_total_accesses)"
    echo "TotalKBytes=$(metrics_total_kbytes)"
    echo "CPULoad=$(metrics_cpu_load)"
    echo "Uptime=$(metrics_uptime)"
    echo "ReqPerSec=$(metrics_req_per_sec)"
    echo "BytesPerSec=$(metrics_bytes_per_sec)"
    echo "BytesPerReq=$(metrics_bytes_per_req)"
    echo "BusyWorkers=$(metrics_busy_workers)"
    echo "IdleWorkers=$(metrics_idle_workers)"
    echo "ConnsTotal=$(metrics_connections_total)"
    echo "ConnsAsyncWriting=$(metrics_connections_writing)"
    echo "ConnsAsyncKeepAlive=$(metrics_connections_keepalive)"
    echo "ConnsAsyncClosing=$(metrics_connections_closing)"
}
