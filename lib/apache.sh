#!/usr/bin/env bash
#
# apache.sh
#
# Apache helper library
#
# Project : zapache-monitor-toolkit
# Version : 2.0.0-alpha
#

#
# Global cache
#

APACHE_STATUS=""
APACHE_STATUS_URL=""
APACHE_HTTP_CLIENT=""

#
# Detect Apache executable
#

apache_binary() {

    if command -v httpd >/dev/null 2>&1; then
        echo httpd
        return
    fi

    if command -v apache2 >/dev/null 2>&1; then
        echo apache2
        return
    fi

    return 1
}

#
# Apache installed?
#

apache_installed() {

    apache_binary >/dev/null
}

#
# Version
#

apache_version() {

    local bin

    bin=$(apache_binary) || return 1

    "$bin" -v | awk -F': ' '/Server version/{print $2}'
}

#
# Apache running?
#

apache_running() {

    systemctl is-active --quiet httpd \
        || systemctl is-active --quiet apache2
}

#
# Detect MPM
#

apache_mpm() {

    local bin

    bin=$(apache_binary) || return 1

    "$bin" -V | awk -F': ' '/Server MPM/{print $2}'
}

#
# Loaded modules
#

apache_modules() {

    local bin

    bin=$(apache_binary) || return 1

    "$bin" -M 2>/dev/null
}

#
# mod_status loaded?
#

apache_mod_status() {

    apache_modules | grep -qi status_module
}

#
# ExtendedStatus
#

apache_extended_status() {

    local cfg

    cfg=$(apache_binary -V 2>/dev/null | awk -F'"' '/SERVER_CONFIG_FILE/{print $2}')

    if [[ -n "$cfg" ]] && grep -Riq "ExtendedStatus[[:space:]]\+On" /etc/httpd /etc/apache2 2>/dev/null; then
        return 0
    fi

    return 1
}

#
# Detect HTTP client
#

apache_detect_client() {

    if command -v curl >/dev/null 2>&1; then
        APACHE_HTTP_CLIENT="curl"
        return
    fi

    if command -v wget >/dev/null 2>&1; then
        APACHE_HTTP_CLIENT="wget"
        return
    fi

    return 1
}

#
# Download server-status
#

apache_fetch_status() {

    local url

    url="${1:-http://127.0.0.1/server-status?auto}"

    apache_detect_client || return 1

    APACHE_STATUS_URL="$url"

    if [[ "$APACHE_HTTP_CLIENT" == "curl" ]]; then

        APACHE_STATUS=$(
            curl \
                --silent \
                --max-time 5 \
                --noproxy "*" \
                "$url"
        )

    else

        APACHE_STATUS=$(
            no_proxy="127.0.0.1,localhost" \
            wget \
                -q \
                -O - \
                "$url"
        )

    fi

    [[ -n "$APACHE_STATUS" ]]
}

#
# Generic metric
#

apache_metric() {

    local key="$1"

    echo "$APACHE_STATUS" \
        | awk -F': ' -v k="$key" '$1==k{print $2}'
}

#
# Scoreboard
#

apache_scoreboard() {

    apache_metric Scoreboard
}

#
# Count scoreboard character
#

apache_scoreboard_count() {

    local char="$1"

    apache_scoreboard \
        | tr -cd "$char" \
        | wc -c
}

#
# Detect access log
#

apache_access_log() {

    local logs=(
        /var/log/httpd/access_log
        /var/log/httpd/*access.log
        /var/log/apache2/access.log
        /var/log/apache2/*access.log
    )

    for f in "${logs[@]}"; do

        for file in $f; do

            [[ -f "$file" ]] && {

                echo "$file"

                return

            }

        done

    done

    return 1
}

#
# Check server-status
#

apache_status_ok() {

    apache_fetch_status "$1" || return 1

    apache_metric Total\ Accesses >/dev/null
}
