#!/usr/bin/env bash
#
# uninstall.sh
#
# zapache-monitor-toolkit Uninstaller
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

PASS=0
FAIL=0

############################################################
# Colours
############################################################

GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
RESET="\033[0m"

############################################################

pass() {

    printf "%-45s ${GREEN}[PASS]${RESET}\n" "$1"
    PASS=$((PASS+1))
}

fail() {

    printf "%-45s ${RED}[FAIL]${RESET}\n" "$1"
    FAIL=$((FAIL+1))
}

warn() {

    printf "%-45s ${YELLOW}[WARN]${RESET}\n" "$1"
}

############################################################

banner() {

cat <<EOF

============================================================
        $PROJECT_NAME Uninstaller
============================================================

Version : $VERSION

EOF

}

############################################################

check_root() {

    if [[ $EUID -ne 0 ]]; then
        echo "Please run as root."
        exit 1
    fi

    pass "Running as root"
}

############################################################

detect_zabbix() {

    if systemctl list-unit-files | grep -q zabbix-agent2; then

        SERVICE="zabbix-agent2"

    elif systemctl list-unit-files | grep -q zabbix-agent; then

        SERVICE="zabbix-agent"

    else

        SERVICE=""

        warn "No Zabbix service detected"

    fi

}

############################################################

confirm() {

    echo
    echo "The following will be removed:"
    echo
    echo "  $INSTALL_DIR"
    echo "  $BIN_DIR/zabbix_apache"
    echo "  $BIN_DIR/test_zapache"
    echo "  $USERPARAMETER_FILE"
    echo
    echo "Configuration can optionally be preserved."
    echo

    read -rp "Continue? [y/N]: " ANSWER

    case "$ANSWER" in
        y|Y|yes|YES)
            ;;
        *)
            echo "Cancelled."
            exit 0
            ;;
    esac
}

############################################################

remove_symlinks() {

    rm -f "$BIN_DIR/zabbix_apache"
    rm -f "$BIN_DIR/test_zapache"

    pass "Removed symbolic links"
}

############################################################

remove_installation() {

    if [[ -d "$INSTALL_DIR" ]]; then

        rm -rf "$INSTALL_DIR"

        pass "Removed toolkit"

    else

        warn "Toolkit directory not found"

    fi
}

############################################################

remove_userparameter() {

    if [[ -f "$USERPARAMETER_FILE" ]]; then

        rm -f "$USERPARAMETER_FILE"

        pass "Removed UserParameter"

    else

        warn "UserParameter not found"

    fi
}

############################################################

remove_configuration() {

    echo

    read -rp "Remove configuration files? [y/N]: " REMOVE_CONFIG

    case "$REMOVE_CONFIG" in

        y|Y|yes|YES)

            rm -rf "$CONFIG_DIR"

            pass "Configuration removed"

            ;;

        *)

            warn "Configuration preserved"

            ;;

    esac
}

############################################################

restart_agent() {

    if [[ -n "$SERVICE" ]]; then

        systemctl restart "$SERVICE"

        pass "Restarted $SERVICE"

    fi
}

############################################################

summary() {

echo

echo "============================================================"
echo "Uninstallation Summary"
echo "============================================================"

echo

echo "Passed : $PASS"
echo "Failed : $FAIL"

echo

if [[ $FAIL -eq 0 ]]; then

    echo -e "${GREEN}Toolkit successfully removed.${RESET}"

else

    echo -e "${RED}Toolkit removed with warnings.${RESET}"

fi

}

############################################################
# Main
############################################################

banner

check_root

detect_zabbix

confirm

remove_symlinks

remove_installation

remove_userparameter

remove_configuration

restart_agent

summary

exit 0
