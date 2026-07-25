#!/usr/bin/env bash
#
# install.sh
#
# zapache-monitor-toolkit Installer
#
# Version : 2.0.0-alpha
#

set -e

VERSION="2.0.0-alpha"

PROJECT_NAME="zapache-monitor-toolkit"

INSTALL_DIR="/opt/zapache-monitor-toolkit"

BIN_DIR="/usr/local/bin"

CONFIG_DIR="/etc/zapache"

ZABBIX_CONF_DIR="/etc/zabbix/zabbix_agentd.d"

CONFIG_FILE="$CONFIG_DIR/zapache.conf"

USERPARAMETER_FILE="$ZABBIX_CONF_DIR/zapache.conf"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

PASS=0
FAIL=0

###########################################################

green() { printf "\033[32m%s\033[0m\n" "$1"; }
red()   { printf "\033[31m%s\033[0m\n" "$1"; }
yellow(){ printf "\033[33m%s\033[0m\n" "$1"; }

###########################################################

pass() {

    printf "%-45s [PASS]\n" "$1"

    PASS=$((PASS+1))
}

fail() {

    printf "%-45s [FAIL]\n" "$1"

    FAIL=$((FAIL+1))
}

###########################################################

banner() {

cat <<EOF

============================================================
        $PROJECT_NAME Installer
============================================================

Version : $VERSION

EOF

}

###########################################################

check_root() {

    if [[ $EUID -ne 0 ]]; then

        red "Please run as root."

        exit 1

    fi

    pass "Running as root"
}

###########################################################

check_dependencies() {

    local deps=(awk grep sed tr wc)

    for cmd in "${deps[@]}"; do

        if command -v "$cmd" >/dev/null 2>&1; then

            pass "$cmd installed"

        else

            fail "$cmd missing"

        fi

    done

    if command -v curl >/dev/null 2>&1; then

        HTTP_CLIENT="curl"

        pass "curl installed"

    elif command -v wget >/dev/null 2>&1; then

        HTTP_CLIENT="wget"

        pass "wget installed"

    else

        fail "No HTTP client found"

        exit 1

    fi
}

###########################################################

detect_apache() {

    if command -v httpd >/dev/null 2>&1; then

        APACHE_BIN=httpd

    elif command -v apache2 >/dev/null 2>&1; then

        APACHE_BIN=apache2

    else

        fail "Apache not found"

        exit 1

    fi

    pass "Apache detected"

    APACHE_VERSION=$($APACHE_BIN -v | head -1)

    echo
    echo "$APACHE_VERSION"

    MPM=$($APACHE_BIN -V 2>/dev/null | grep "Server MPM" | cut -d: -f2)

    echo "MPM : $MPM"
}

###########################################################

detect_zabbix() {

    if systemctl list-unit-files | grep -q zabbix-agent2; then

        SERVICE="zabbix-agent2"

    elif systemctl list-unit-files | grep -q zabbix-agent; then

        SERVICE="zabbix-agent"

    else

        fail "Zabbix Agent not installed"

        exit 1

    fi

    pass "Zabbix Agent detected"
}

###########################################################

detect_logfile() {

    LOGFILE=""

    for file in \
        /var/log/httpd/internet-access.log \
        /var/log/httpd/intranet-access.log \
        /var/log/httpd/access.log \
        /var/log/httpd/access_log \
        /var/log/apache2/access.log
    do

        if [[ -f "$file" ]]; then

            LOGFILE="$file"

            break

        fi

    done

    if [[ -z "$LOGFILE" ]]; then

        yellow "No access log detected."

        read -rp "Enter logfile path: " LOGFILE

    fi

    pass "Access log detected"

    echo "Logfile : $LOGFILE"
}

###########################################################

create_directories() {

    mkdir -p "$INSTALL_DIR"

    mkdir -p "$CONFIG_DIR"

    mkdir -p "$ZABBIX_CONF_DIR"

    pass "Directories created"
}

###########################################################

copy_files() {

    cp -r lib "$INSTALL_DIR"

    cp bin/zabbix_apache "$INSTALL_DIR"

    cp bin/test_zapache.sh "$INSTALL_DIR"

    cp -r examples "$INSTALL_DIR"

    cp -r docs "$INSTALL_DIR"

    cp -r samples "$INSTALL_DIR"

    chmod +x "$INSTALL_DIR/zabbix_apache"

    chmod +x "$INSTALL_DIR/test_zapache.sh"

    ln -sf "$INSTALL_DIR/zabbix_apache" "$BIN_DIR/zabbix_apache"

    ln -sf "$INSTALL_DIR/test_zapache.sh" "$BIN_DIR/test_zapache"

    pass "Toolkit installed"
}

###########################################################

create_config() {

cat > "$CONFIG_FILE" <<EOF
APACHE_STATUS_URL=http://127.0.0.1/server-status?auto
LOGFILE=$LOGFILE
HTTP_CLIENT=$HTTP_CLIENT
DEBUG=0
EOF

    pass "Configuration created"
}

###########################################################

create_userparameter() {

cat > "$USERPARAMETER_FILE" <<EOF
UserParameter=apache.status[*],$INSTALL_DIR/zabbix_apache "\$1"
EOF

    pass "UserParameter installed"
}

###########################################################

restart_agent() {

    systemctl restart "$SERVICE"

    pass "Restarted $SERVICE"
}

###########################################################

verify() {

    echo

    echo "Running toolkit verification..."

    "$INSTALL_DIR/test_zapache.sh" >/dev/null

    if [[ $? -eq 0 ]]; then

        pass "Toolkit verified"

    else

        fail "Toolkit verification"

    fi
}

###########################################################

summary() {

echo

echo "============================================================"

echo "Installation Summary"

echo "============================================================"

echo

echo "Install directory : $INSTALL_DIR"

echo "Configuration     : $CONFIG_FILE"

echo "UserParameter     : $USERPARAMETER_FILE"

echo "Logfile           : $LOGFILE"

echo

echo "Passed : $PASS"

echo "Failed : $FAIL"

echo

if [[ $FAIL -eq 0 ]]; then

    green "Installation completed successfully."

else

    red "Installation completed with warnings."

fi

}

###########################################################

banner

check_root

check_dependencies

detect_apache

detect_zabbix

detect_logfile

create_directories

copy_files

create_config

create_userparameter

restart_agent

verify

summary

exit 0
