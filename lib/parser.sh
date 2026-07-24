#!/usr/bin/env bash
#
# parser.sh
#
# Apache Log Parser Library
#
# Project : zapache-monitor-toolkit
# Version : 2.0.0-alpha
#

#
# Default logfile
#

PARSER_LOGFILE=""

#
# Set logfile
#

parser_set_logfile() {

    PARSER_LOGFILE="$1"
}

#
# Return logfile
#

parser_get_logfile() {

    echo "$PARSER_LOGFILE"
}

#
# Verify logfile exists
#

parser_log_exists() {

    [[ -f "$PARSER_LOGFILE" ]]
}

#
# Detect current timestamp (previous minute)
#

parser_time_pattern() {

    date --date='1 minute ago' +'%d/%b/%Y:%H:%M'
}

#
# Generic tail
#

parser_tail() {

    local lines="${1:-5000}"

    tail -n "$lines" "$PARSER_LOGFILE"
}

#
# Count matching lines
#

parser_count() {

    local regex="$1"

    parser_tail | grep -E "$regex" | wc -l
}

#
# Count lines for previous minute
#

parser_count_minute() {

    local regex="$1"

    parser_tail \
        | grep "$(parser_time_pattern)" \
        | grep -E "$regex" \
        | wc -l
}

#
# Count HTTP response codes
#

parser_count_http() {

    local class="$1"

    parser_count_minute "\" ${class}[0-9][0-9] "
}

#
# HTTP 2xx
#

parser_http2xx() {

    parser_count_http 2
}

#
# HTTP 3xx
#

parser_http3xx() {

    parser_count_http 3
}

#
# HTTP 4xx
#

parser_http4xx() {

    parser_count_http 4
}

#
# HTTP 5xx
#

parser_http5xx() {

    parser_count_http 5
}

#
# Detect Common Log Format
#

parser_is_clf() {

    head -1 "$PARSER_LOGFILE" \
        | grep -Eq \
        '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ .*" [0-9]{3} '
}

#
# Detect Combined Log Format
#

parser_is_combined() {

    head -1 "$PARSER_LOGFILE" \
        | grep -Eq \
        '".*" "[^"]*" "[^"]*"'
}

#
# Detect JSON log
#

parser_is_json() {

    head -1 "$PARSER_LOGFILE" \
        | grep -q '^{'
}

#
# Auto detect log format
#

parser_detect_format() {

    if parser_is_json; then

        echo "json"

        return

    fi

    if parser_is_combined; then

        echo "combined"

        return

    fi

    if parser_is_clf; then

        echo "common"

        return

    fi

    echo "unknown"
}

#
# Detect HTTP status column
#

parser_detect_status_column() {

    awk '

    NR==1 {

        for(i=1;i<=NF;i++){

            if($i~/^[1-5][0-9][0-9]$/){

                print i

                exit

            }

        }

    }

    ' "$PARSER_LOGFILE"
}

#
# Generic status counter
#

parser_status_count() {

    local code="$1"

    local field

    field=$(parser_detect_status_column)

    parser_tail |

    awk -v f="$field" -v c="$code" '

        $f==c{

            n++

        }

        END{

            print n+0

        }

    '
}

#
# Display parser information
#

parser_info() {

    echo "Logfile       : $PARSER_LOGFILE"

    echo "Format        : $(parser_detect_format)"

    echo "Status Column : $(parser_detect_status_column)"
}

#
# Test parser
#

parser_selftest() {

    echo "Parser Version : 2.0.0-alpha"

    parser_info

    echo

    echo "2xx : $(parser_http2xx)"

    echo "3xx : $(parser_http3xx)"

    echo "4xx : $(parser_http4xx)"

    echo "5xx : $(parser_http5xx)"
}
