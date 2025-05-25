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
  # https://github.com/nextcloud/server/issues/52791 (fixed in Nextcloud 32, currently unreleased)
  if (
    tag == 'nextcloud-preview-gen.service' and
    'Cached preview not found for file' in e['MESSAGE']
  ):
    return True
  if source.startswith('.php-fpm') or source == 'dockerd':
    return e['PRIORITY'] >= LOG_ERR

  if source == 'kernel':
    return e['PRIORITY'] >= LOG_INFO
  if source != 'systemd':
    # ignore non-systemd notice and below
    return e['PRIORITY'] >= LOG_NOTICE

  unit = e.get('UNIT', '')
  return (
    e['PRIORITY'] >= LOG_NOTICE and (
      unit in {
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
        re.match(r'music-dl(-.+)?\.(service|target)$', unit)
        or re.match(r'yt-wl-trasher.(service|timer)$', unit)
        or re.match(r'system-music\\x2ddl.+slice$', unit)
        or re.match(r'.+\.(auto)?mount$', unit)
        or re.match(r'acme-.+\.service$', unit)
        or re.match(r'yt-store-cookies@.+\.service$', unit)
        or re.match(r'yt-store-dl-cookies@.+\.service$', unit)
        or re.match(r'syncoid-.+\.service$', unit)
      )
    )
  ) or (
    e['PRIORITY'] >= LOG_INFO and (
      re.match(r'zfs-snapshot-\w+\.service$', unit)
      or unit == 'sanoid.service'
      or unit == 'systemd-tmpfiles-clean.service'
      or re.match(r'run-credentials-systemd.+tmpfiles.+clean$', unit)
      or unit == 'logrotate.service'
      or unit == 'ddclient.service'
      or re.match(r'nginx(-config-reload)?\.service$', unit)
      or re.match(r'run-docker-runtime.+.mount$$', unit)
      or unit == 'nscd.service'
      or unit == 'nss-lookup.target'
      or unit == 'nss-user-lookup.target'
    )
  )