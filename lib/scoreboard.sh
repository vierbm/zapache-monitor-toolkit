#!/usr/bin/env bash
#
# scoreboard.sh
#
# Apache Scoreboard Library
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
# Return the raw scoreboard string
#

scoreboard_raw() {

    apache_scoreboard
}

#
# Generic character counter
#

scoreboard_count() {

    local character="$1"

    scoreboard_raw |
        tr -cd "$character" |
        wc -c
}

#
# Waiting for Connection (_)
#

scoreboard_waiting() {

    scoreboard_count "_"
}

#
# Starting Up (S)
#

scoreboard_starting() {

    scoreboard_count "S"
}

#
# Reading Request (R)
#

scoreboard_reading() {

    scoreboard_count "R"
}

#
# Sending Reply (W)
#

scoreboard_sending() {

    scoreboard_count "W"
}

#
# KeepAlive (K)
#

scoreboard_keepalive() {

    scoreboard_count "K"
}

#
# DNS Lookup (D)
#

scoreboard_dnslookup() {

    scoreboard_count "D"
}

#
# Closing Connection (C)
#

scoreboard_closing() {

    scoreboard_count "C"
}

#
# Logging (L)
#

scoreboard_logging() {

    scoreboard_count "L"
}

#
# Gracefully Finishing (G)
#

scoreboard_graceful() {

    scoreboard_count "G"
}

#
# Idle Cleanup (I)
#

scoreboard_idle_cleanup() {

    scoreboard_count "I"
}

#
# Open Slot (.)
#

scoreboard_open_slot() {

    scoreboard_count "."
}

#
# Busy Workers
#
# Busy workers are all non-idle worker states.
#

scoreboard_busy() {

    local total=0

    total=$((

        $(scoreboard_starting) +
        $(scoreboard_reading) +
        $(scoreboard_sending) +
        $(scoreboard_keepalive) +
        $(scoreboard_dnslookup) +
        $(scoreboard_closing) +
        $(scoreboard_logging) +
        $(scoreboard_graceful) +
        $(scoreboard_idle_cleanup)

    ))

    echo "$total"
}

#
# Idle Workers
#

scoreboard_idle() {

    scoreboard_waiting
}

#
# Total Scoreboard Slots
#

scoreboard_total() {

    echo "${#$(scoreboard_raw)}"
}

#
# Print scoreboard statistics
#

scoreboard_dump() {

    cat <<EOF
WaitingForConnection      : $(scoreboard_waiting)
StartingUp                : $(scoreboard_starting)
ReadingRequest            : $(scoreboard_reading)
SendingReply              : $(scoreboard_sending)
KeepAlive                 : $(scoreboard_keepalive)
DNSLookup                 : $(scoreboard_dnslookup)
ClosingConnection         : $(scoreboard_closing)
Logging                   : $(scoreboard_logging)
GracefullyFinishing       : $(scoreboard_graceful)
IdleCleanupOfWorker       : $(scoreboard_idle_cleanup)
OpenSlotWithNoProcess     : $(scoreboard_open_slot)

BusyWorkers               : $(scoreboard_busy)
IdleWorkers               : $(scoreboard_idle)

TotalSlots                : $(scoreboard_total)
EOF
}

#
# Self-test
#

scoreboard_selftest() {

    echo "Apache Scoreboard Library"
    echo "Version: 2.0.0-alpha"
    echo

    scoreboard_dump
}
