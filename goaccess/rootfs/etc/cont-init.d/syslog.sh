#!/usr/bin/with-contenv bashio
# ==============================================================================
# Configures syslog-ng (nginx syslog receiver) and logrotate
# ==============================================================================

# shellcheck shell=bash

mkdir -p /data/logs

# GoAccess fails to start if a configured log file is missing
if [ ! -f /data/logs/nginx-access.log ]; then
    touch /data/logs/nginx-access.log
fi

# The @version header must match the installed syslog-ng config version
SYSLOG_NG_VERSION=$(syslog-ng --version | sed -n 's/^Config version:[[:space:]]*//p')
if [ -z "${SYSLOG_NG_VERSION}" ]; then
    bashio::log.warning "Could not detect syslog-ng config version, defaulting to 3.35"
    SYSLOG_NG_VERSION="3.35"
fi

bashio::log.info "Generating syslog-ng configuration (version ${SYSLOG_NG_VERSION})..."

cat > /etc/syslog-ng/syslog-ng.conf <<EOF
@version: ${SYSLOG_NG_VERSION}

options {
    keep-hostname(yes);
    create-dirs(yes);
    stats-freq(0);
};

source s_network {
    network(transport("udp") ip("0.0.0.0") port(514));
    network(transport("tcp") ip("0.0.0.0") port(514) max-connections(50) log-iw-size(5000));
};

destination d_access {
    file("/data/logs/nginx-access.log" template("\${MESSAGE}\n") template-escape(no));
};

log {
    source(s_network);
    destination(d_access);
};
EOF

LOG_ROTATE_KEEP=$(bashio::config 'log_rotate_keep' '7')
LOG_ROTATE_MAXSIZE=$(bashio::config 'log_rotate_maxsize' '50M')

bashio::log.info "Generating logrotate configuration (keep: ${LOG_ROTATE_KEEP}, maxsize: ${LOG_ROTATE_MAXSIZE})..."

# copytruncate keeps the inode stable so syslog-ng (O_APPEND) and the
# GoAccess tail keep working across rotations without being signaled
cat > /etc/logrotate-goaccess.conf <<EOF
/data/logs/*.log {
    daily
    maxsize ${LOG_ROTATE_MAXSIZE}
    rotate ${LOG_ROTATE_KEEP}
    missingok
    notifempty
    copytruncate
    compress
    delaycompress
}
EOF
