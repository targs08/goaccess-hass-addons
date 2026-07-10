#!/usr/bin/with-contenv bashio
# ==============================================================================
# Configures GoAccess
# ==============================================================================

# shellcheck shell=bash

# /config (addon_config) may not be mounted on newer Supervisor versions;
# fall back to the always-available /data directory in that case
CONFIG_DIR=/config
if ! bashio::fs.directory_exists /config; then
    bashio::log.warning "/config is not mounted, storing goaccess.conf in /data instead"
    CONFIG_DIR=/data
fi

if [ ! -f "${CONFIG_DIR}/goaccess.conf" ]; then
    bashio::log.info "No configuration file found, copying default one"
    cp /usr/goaccess/goaccess.default.conf "${CONFIG_DIR}/goaccess.conf"
fi
