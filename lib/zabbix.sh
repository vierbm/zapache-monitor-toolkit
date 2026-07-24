#!/usr/bin/env bash
#
# zabbix.sh
#
# Zabbix Integration Library
#
# Project : zapache-monitor-toolkit
# Version : 2.0.0-alpha
#

#
# Requires
#
#   apache.sh
#   metrics.sh
#   scoreboard.sh
#   parser.sh
#

ZABBIX_VERSION="2.0.0-alpha"

#
# Print Zabbix NOTSUPPORTED
#

zabbix_notsupported() {

    echo "ZBX_NOTSUPPORTED"
    return 1
}

#
# Return toolkit version
#

zabbix_version() {

    echo "$ZABBIX_VERSION"
}

#
# Validate requested key
#

zabbix_validate_key() {

    [[ -n "$1" ]]
}

#
# Return a metric
#

zabbix_get_metric() {

    local key="$1"

    case "$key" in

        #
        # Runtime Metrics
        #

        TotalAccesses)

            metrics_total_accesses
            ;;

        TotalKBytes)

            metrics_total_kbytes
            ;;

        CPULoad)

            metrics_cpu_load
            ;;

        Uptime)

            metrics_uptime
            ;;

        ReqPerSec)

            metrics_req_per_sec
            ;;

        BytesPerSec)

            metrics_bytes_per_sec
            ;;

        BytesPerReq)

            metrics_bytes_per_req
            ;;

        BusyWorkers)

            metrics_busy_workers
            ;;

        IdleWorkers)

            metrics_idle_workers
            ;;

        ConnsTotal)

            metrics_connections_total
            ;;

        ConnsAsyncWriting)

            metrics_connections_writing
            ;;

        ConnsAsyncKeepAlive)

            metrics_connections_keepalive
            ;;

        ConnsAsyncClosing)

            metrics_connections_closing
            ;;

        #
        # Scoreboard
        #

        WaitingForConnection)

            scoreboard_waiting
            ;;

        StartingUp)

            scoreboard_starting
            ;;

        ReadingRequest)

            scoreboard_reading
            ;;

        SendingReply)

            scoreboard_sending
            ;;

        KeepAlive)

            scoreboard_keepalive
            ;;

        DNSLookup)

            scoreboard_dnslookup
            ;;

        ClosingConnection)

            scoreboard_closing
            ;;

        Logging)

            scoreboard_logging
            ;;

        GracefullyFinishing)

            scoreboard_graceful
            ;;

        IdleCleanupOfWorker)

            scoreboard_idle_cleanup
            ;;

        OpenSlotWithNoCurrentProcess)

            scoreboard_open_slot
            ;;

        #
        # Log Metrics
        #

        Http40xErrCount)

            parser_http4xx
            ;;

        Http50xErrCount)

            parser_http5xx
            ;;

        #
        # Toolkit Version
        #

        version)

            zabbix_version
            ;;

        *)

            zabbix_notsupported
            ;;
    esac
}

#
# Main dispatcher
#

zabbix_run() {

    local key="$1"

    zabbix_validate_key "$key" || {

        zabbix_notsupported

        return

    }

    #
    # Fetch Apache status only if needed
    #

    case "$key" in

        Http40xErrCount|Http50xErrCount|version)

            ;;

        *)

            apache_fetch_status || {

                zabbix_notsupported

                return

            }

            ;;
    esac

    zabbix_get_metric "$key"
}

#
# List supported metrics
#

zabbix_list_metrics() {

cat <<EOF
TotalAccesses
TotalKBytes
CPULoad
Uptime
ReqPerSec
BytesPerSec
BytesPerReq
BusyWorkers
IdleWorkers
ConnsTotal
ConnsAsyncWriting
ConnsAsyncKeepAlive
ConnsAsyncClosing
WaitingForConnection
StartingUp
ReadingRequest
SendingReply
KeepAlive
DNSLookup
ClosingConnection
Logging
GracefullyFinishing
IdleCleanupOfWorker
OpenSlotWithNoCurrentProcess
Http40xErrCount
Http50xErrCount
version
EOF

}

#
# Self Test
#

zabbix_selftest() {

    echo "Zabbix Library"
    echo "Version : $ZABBIX_VERSION"
    echo

    echo "Supported Metrics"
    echo "-----------------"

    zabbix_list_metrics
}
