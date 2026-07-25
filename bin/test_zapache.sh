#!/usr/bin/env bash
#
# test_zapache.sh
#
# Apache/Zabbix Health Check
#

SCRIPT="./zabbix_apache"
URL="http://127.0.0.1/server-status?auto"
LOGFILE="/var/log/httpd/internet-access.log"

PASS=0
FAIL=0

GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
BLUE="\033[34m"
NC="\033[0m"

pass() {
    printf "%-45s ${GREEN}[PASS]${NC}\n" "$1"
    ((PASS++))
}

fail() {
    printf "%-45s ${RED}[FAIL]${NC}\n" "$1"
    ((FAIL++))
}

warn() {
    printf "%-45s ${YELLOW}[WARN]${NC}\n" "$1"
}

echo
echo "============================================================"
echo "          Apache / Zabbix Health Check"
echo "============================================================"

###############################################################
# Locate Apache
###############################################################

if command -v httpd >/dev/null 2>&1; then
    APACHE=httpd
elif command -v apache2 >/dev/null 2>&1; then
    APACHE=apache2
else
    fail "Apache installed"
    exit 1
fi

pass "Apache installed"

###############################################################
# Apache version
###############################################################

VERSION=$($APACHE -v | head -1)

echo
echo "$VERSION"

###############################################################
# MPM
###############################################################

MPM=$($APACHE -V 2>/dev/null | awk -F': ' '/Server MPM/ {print $2}')

if [[ -n "$MPM" ]]; then
    echo "MPM                 : $MPM"
else
    warn "Unable to determine MPM"
fi

###############################################################
# Running
###############################################################

if pgrep -x "$APACHE" >/dev/null; then
    pass "Apache running"
else
    fail "Apache running"
fi

###############################################################
# Modules
###############################################################

MODULES=$($APACHE -M 2>/dev/null)

if echo "$MODULES" | grep -q status_module; then
    pass "mod_status loaded"
else
    fail "mod_status loaded"
fi

###############################################################
# Fetch server-status
###############################################################

STATUS=$(wget -q -O - "$URL")

if [[ -z "$STATUS" ]]; then
    fail "/server-status reachable"
    exit 1
fi

if echo "$STATUS" | grep -q "^BusyWorkers:"; then
    pass "/server-status reachable"
else
    fail "/server-status reachable"
fi

###############################################################
# ExtendedStatus
###############################################################

if echo "$STATUS" | grep -q "^ReqPerSec:" &&
   echo "$STATUS" | grep -q "^Scoreboard:" &&
   echo "$STATUS" | grep -q "^BusyWorkers:"; then

    pass "ExtendedStatus enabled"

else

    fail "ExtendedStatus enabled"

fi

###############################################################
# Logfile
###############################################################

if [[ -f "$LOGFILE" ]]; then
    pass "Access log exists"
else
    fail "Access log exists ($LOGFILE)"
fi

###############################################################
# Script executable
###############################################################

if [[ -x "$SCRIPT" ]]; then
    pass "zabbix_apache executable"
else
    fail "zabbix_apache executable"
fi

###############################################################
# Metrics
###############################################################

echo
echo "============================================================"
echo "Testing Metrics"
echo "============================================================"

METRICS=(
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
)

for metric in "${METRICS[@]}"
do

    if [[ "$metric" == "Http40xErrCount" || \
          "$metric" == "Http50xErrCount" || \
          "$metric" == "version" ]]; then

        VALUE=$("$SCRIPT" "$metric")

    else

        VALUE=$("$SCRIPT" "$metric" "$URL")

    fi

    RC=$?

    if [[ $RC -eq 0 && -n "$VALUE" && "$VALUE" != "ZBX_NOTSUPPORTED" ]]; then

        printf "%-35s %-20s ${GREEN}[PASS]${NC}\n" "$metric" "$VALUE"
        ((PASS++))

    else

        printf "%-35s %-20s ${RED}[FAIL]${NC}\n" "$metric" "$VALUE"
        ((FAIL++))

    fi

done

###############################################################
# Scoreboard Summary
###############################################################

echo
echo "============================================================"
echo "Apache Scoreboard"
echo "============================================================"

echo "$STATUS" | grep "^Scoreboard:"

echo
echo "============================================================"
echo "Apache Runtime"
echo "============================================================"

echo "$STATUS"

###############################################################
# Summary
###############################################################

echo
echo "============================================================"
echo "Summary"
echo "============================================================"

printf "Passed : %d\n" "$PASS"
printf "Failed : %d\n" "$FAIL"

if [[ $FAIL -eq 0 ]]; then
    echo
    echo -e "${GREEN}✔ Apache monitoring appears to be fully operational.${NC}"
else
    echo
    echo -e "${RED}✘ One or more checks failed.${NC}"
fi

exit $FAIL
