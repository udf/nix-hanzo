import re
import os
from systemd.journal import LOG_INFO, LOG_NOTICE, LOG_ERR

owner = 232787997
token = os.environ['TOKEN']

flood_server_url = 'http://127.0.0.1:3000'

def systemd_should_ignore(e):
  source = e.get('_COMM') or e.get('SYSLOG_IDENTIFIER')
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
        'yt-music-dl.service',
        'flood-cleanup.service',
        'zpool-trim.service',
        'nextcloud-cron.service',
        'szuru-ocrbot.service',
      }
    )
  ) or (
    e['PRIORITY'] >= LOG_INFO and (
      re.match(r'zfs-snapshot-\w+\.service', unit)
      or unit == 'systemd-tmpfiles-clean.service'
      or re.match(r'run-credentials-systemd.+tmpfiles.+clean', unit)
      or unit == 'logrotate.service'
      or re.match(r'acme-.+\.service', unit)
      or unit == 'ddclient.service'
      or re.match(r'nginx(-config-reload)?\.service', unit)
      or re.match(r'run-docker-runtime.+.mount$', unit)
    )
  )