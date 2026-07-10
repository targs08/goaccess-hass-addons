# Home Assistant Add-on: GoAccess

[GoAccess](https://goaccess.io) is an open source **real-time web log analyzer** and interactive viewer.

## Installation

Follow these steps to get the add-on installed on your system:

1. Click here:

   [![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2FTECH7Fox%2Fgoaccess-hass-addons)

1. Scroll down the page to find the new repository, and click in the new add-on named **_GoAccess_**.
1. Click in the **_INSTALL_** button.

## Using

1. Start the add-on to create the default `goaccess/conf` configuration file which will be located in the `addon_configs/VERSION_goaccess` folder. You need to add your log files to the configuration file.
Go to [Configuring GoAccess](#configuring-goaccess) for more info on how to configure GoAccess.
2. Start the add-on again by clicking in the **_START_** button. You should now be able to access the GoAccess web interface by clicking in the **_OPEN WEB UI_** button.

## Configuring GoAccess

The add-on uses the `goaccess.conf` file located in the `addon_configs` folder to configure GoAccess. You can modify this file to suit your needs.

Here is a example for a Nginx Proxy Manager log file:
```conf
log-file /addon_configs/local_nginxproxymanager/logs/proxy-host-1_access.log
log-file /addon_configs/local_nginxproxymanager/logs/proxy-host-2_access.log
```

You can add as many log files as you want.

By default, GoAccess is configured for the Nginx Proxy Manager log format. You can change the log format in the `goaccess.conf` file. Search for the `log-format` option and change it to the desired format.

**Note**: _Remember to restart the add-on when the GoAccess configuration has changed._

## Receiving logs via syslog

Instead of (or in addition to) reading log files from disk, the add-on runs a
syslog receiver (syslog-ng) listening on port **514** (UDP and TCP). Every log
line received is appended to `/data/logs/nginx-access.log` inside the add-on's
private data directory, which is already enabled in the default `goaccess.conf`:

```conf
log-file /data/logs/nginx-access.log
```

syslog-ng writes each received line exactly as nginx formatted it, so GoAccess
parses it as long as the sender uses the same format as the `log-format` option
in `goaccess.conf`. The default configuration expects the Nginx Proxy Manager
`proxy` log format. GoAccess supports only **one** log format for all of its
log files, so every sender (and every file-based log source) must use the same
format.

For **Nginx Proxy Manager**, add this to the **Custom Nginx Configuration** of
a proxy host — the `proxy` format is already defined by NPM and matches the
default `goaccess.conf`:

```nginx
access_log syslog:server=<home-assistant-ip>:514,tag=nginx proxy;
```

For a **plain nginx** instance, define the same format first:

```nginx
log_format proxy '[$time_local] $upstream_cache_status $upstream_status $status - $request_method $scheme $host "$request_uri" [Client $remote_addr] [Length $body_bytes_sent] [Gzip $gzip_ratio] [Sent-to $server] "$http_user_agent" "$http_referer"';
access_log syslog:server=<home-assistant-ip>:514,tag=nginx proxy;
```

Alternatively, send any other format (e.g. `combined`) and change `log-format`
in `goaccess.conf` accordingly (e.g. `log-format COMBINED`).

Note that nginx only supports UDP for `syslog:` targets — if you need TCP
delivery, use a local syslog daemon on the sender that forwards to port 514/TCP
of this add-on.

### Log rotation

Received log files are rotated automatically:

- once a day, and additionally as soon as a file grows beyond
  **Maximum log size** (`log_rotate_maxsize`, default `50M`);
- rotated files are compressed and the last **Rotated logs to keep**
  (`log_rotate_keep`, default `7`) copies are kept.

Rotation uses `copytruncate`, so GoAccess and syslog-ng keep working across
rotations without restarts. Note that GoAccess real-time statistics are kept in
memory, so already-parsed data is not lost when the file is rotated; after an
add-on restart only the lines still present in the kept files are re-parsed.

## GeoIP

The add-on includes the free [DB IP](https://db-ip.com) database for GeoIP lookups, and is enabled by default.

To use your own database or update the existing one, you can add the mmdb files to the add-on configuration folder in `/addon_configs/` and update the `goaccess.conf` file to point to the new databases. You can download the latest version at [db-ip.com](https://db-ip.com/db/lite.php).

## Troubleshooting

If you have issues with the add-on, please check the [issue tracker](https://github.com/TECH7Fox/goaccess-hass-addons/issues) for similar issues before creating a new one.
