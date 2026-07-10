FROM ghcr.io/hassio-addons/debian-base:7.3.4 AS base

SHELL [ "/bin/bash", "-euxo", "pipefail", "-c" ]

RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    libgeoip-dev \
    wget \
    gpg \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN wget -qO - https://deb.goaccess.io/gnugpg.key | gpg --dearmor | tee /usr/share/keyrings/goaccess.gpg >/dev/null \
    && echo "deb [signed-by=/usr/share/keyrings/goaccess.gpg arch=$(dpkg --print-architecture)] https://deb.goaccess.io/ bookworm main" | tee /etc/apt/sources.list.d/goaccess.list \
    && apt-get update && apt-get install -y --no-install-recommends goaccess \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY rootfs /

# db-ip.com only hosts the most recent monthly releases, so the month is
# computed at build time (falling back to the previous month around the
# start of a month, before the new release is published).
RUN this_month=$(date +%Y-%m); \
    prev_month=$(date -d "$(date +%Y-%m-15) -1 month" +%Y-%m); \
    for db in country city asn; do \
        wget -qO "dbip-${db}.mmdb.gz" "https://download.db-ip.com/free/dbip-${db}-lite-${this_month}.mmdb.gz" \
            || wget -qO "dbip-${db}.mmdb.gz" "https://download.db-ip.com/free/dbip-${db}-lite-${prev_month}.mmdb.gz"; \
        gunzip "dbip-${db}.mmdb.gz"; \
        mv "dbip-${db}.mmdb" "/usr/dbip/dbip-${db}.mmdb"; \
    done
