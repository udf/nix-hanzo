import re
import os
import sys
import logging
from systemd.journal import LOG_INFO, LOG_NOTICE, LOG_ERR

logger = logging.getLogger('config')
owner = 232787997
token = os.environ['TOKEN']

flood_server_url = 'http://127.0.0.1:3000'
flood_username = os.environ.get('FLOOD_USERNAME')
flood_password = os.environ.get('FLOOD_PASSWORD')

def systemd_should_ignore(e, tag):
  source = e.get('_COMM') or e.get('SYSLOG_IDENTIFIER')
  if (tag == 'podman-pihole.service' and
      e['MESSAGE'].startswith('tail: /var/log/pihole/FTL.log: file truncated')):
    return True
  if source.startswith('.php-fpm') or source == 'dockerd':
    return e['PRIORITY'] >= LOG_ERR

  if source == 'kernel':
    return e['PRIORITY'] >= LOG_INFO or (
      e['PRIORITY'] >= LOG_NOTICE and (
        re.match(r'r8152 .+: Promiscuous mode enabled', e['MESSAGE'])
      )
    )
  if source != 'systemd':
    # ignore non-systemd notice and below
    return e['PRIORITY'] >= LOG_NOTICE

  return (
    e['PRIORITY'] >= LOG_NOTICE and (
      tag in {
        'backup-root.service',
        'fstrim.service',
        'nix-gc.service',
        'yt-wl-dl.service',
        'yt-wl-fetch.service',
        'flood-cleanup.service',
        'zpool-trim.service',
        'nextcloud-cron.service',
        'szuru-ocrbot.service',
        'nextcloud-preview-gen.service',
        'NetworkManager-dispatcher.service',
      }
      or (
        re.match(r'music-dl(-.+)?\.(service|target)$', tag)
        or re.match(r'yt-wl-trasher.(service|timer)$', tag)
        or re.match(r'system-music\\x2ddl.+slice$', tag)
        or re.match(r'.+\.(auto)?mount$', tag)
        or re.match(r'acme-.+\.service$', tag)
        or re.match(r'yt-store-cookies@.+\.service$', tag)
        or re.match(r'yt-store-dl-cookies@.+\.service$', tag)
        or re.match(r'syncoid-.+\.service$', tag)
      )
    )
  ) or (
    e['PRIORITY'] >= LOG_INFO and (
      re.match(r'zfs-snapshot-\w+\.service$', tag)
      or tag == 'sanoid.service'
      or tag == 'systemd-tmpfiles-clean.service'
      or re.match(r'run-credentials-systemd.+tmpfiles.+clean$', tag)
      or tag == 'logrotate.service'
      or tag == 'ddclient.service'
      or re.match(r'nginx(-config-reload)?\.service$', tag)
      or re.match(r'run-docker-runtime.+.mount$$', tag)
      or tag == 'nscd.service'
      or tag == 'nss-lookup.target'
      or tag == 'nss-user-lookup.target'
    )
  )