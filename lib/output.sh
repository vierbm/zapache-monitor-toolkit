#!/usr/bin/env bash
#
# output.sh
#
# Output Formatting Library
#
# Project : zapache-monitor-toolkit
# Version : 2.0.0-alpha
#

#
# ANSI Colors
#

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
WHITE="\033[37m"
BOLD="\033[1m"
RESET="\033[0m"

#
# Banner
#

output_banner() {

    echo
    echo "============================================================"
    echo "          Apache / Zabbix Health Check"
    echo "============================================================"
}

#
# Section Header
#

output_section() {

    echo
    echo "============================================================"
    echo " $1"
    echo "============================================================"
}

#
# PASS
#

output_pass() {

    printf "%-40s ${GREEN}[PASS]${RESET}\n" "$1"
}

#
# FAIL
#

output_fail() {

    printf "%-40s ${RED}[FAIL]${RESET}\n" "$1"
}

#
# WARN
#

output_warn() {

    printf "%-40s ${YELLOW}[WARN]${RESET}\n" "$1"
}

#
# INFO
#

output_info() {

    printf "%-40s ${BLUE}[INFO]${RESET}\n" "$1"
}

#
# DEBUG
#

output_debug() {

    if [[ "$DEBUG" == "1" ]]; then
        printf "%-40s ${MAGENTA}[DEBUG]${RESET}\n" "$1"
    fi
}

#
# Metric Output
#

output_metric() {

    local name="$1"
    local value="$2"

    printf "%-35s %-20s\n" "$name" "$value"
}

#
# Metric Result
#

output_metric_result() {

    local metric="$1"
    local value="$2"
    local status="$3"

    if [[ "$status" == "PASS" ]]; then

        printf "%-35s %-20s ${GREEN}[PASS]${RESET}\n" \
            "$metric" "$value"

    else

        printf "%-35s %-20s ${RED}[FAIL]${RESET}\n" \
            "$metric" "$value"

    fi
}

#
# Key / Value
#

output_keyvalue() {

    printf "%-25s : %s\n" "$1" "$2"
}

#
# Horizontal Rule
#

output_hr() {

    printf '=%.0s' {1..60}
    echo
}

#
# Empty Line
#

output_blank() {

    echo
}

#
# Summary
#

output_summary() {

    local passed="$1"
    local failed="$2"

    output_section "Summary"

    echo "Passed : $passed"
    echo "Failed : $failed"

    echo

    if [[ "$failed" -eq 0 ]]; then

        echo -e "${GREEN}✔ All tests passed.${RESET}"

    else

        echo -e "${RED}✘ One or more tests failed.${RESET}"

    fi
}

#
# Apache Runtime Dump
#

output_runtime() {

    output_section "Apache Runtime"

    metrics_dump
}

#
# Scoreboard
#

output_scoreboard() {

    output_section "Apache Scoreboard"

    echo "$1"
}

#
# Version
#

output_version() {

    echo "zapache-monitor-toolkit"
    echo "Version : 2.0.0-alpha"
}

#
# Error
#

output_error() {

    echo -e "${RED}ERROR:${RESET} $1" >&2
}

#
# Success
#

output_success() {

    echo -e "${GREEN}$1${RESET}"
}

#
# Header
#

output_header() {

    echo
    echo "${BOLD}$1${RESET}"
    output_hr
}
