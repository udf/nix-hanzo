import re
import os
from systemd.journal import LOG_INFO, LOG_NOTICE

owner = 232787997
token = os.environ['TOKEN']

flood_server_url = 'http://127.0.0.1:3000'

def systemd_should_ignore(e):
  source = e.get('_COMM') or e.get('SYSLOG_IDENTIFIER')
  if source == 'kernel':
    return e['PRIORITY'] >= LOG_INFO
  if source != 'systemd':
    # ignore non-systemd notice and below
    return e['PRIORITY'] >= LOG_NOTICE

  unit = e.get('UNIT', '')
  #TODO: ignore acme and nginx
  return (
    e['PRIORITY'] >= LOG_NOTICE and (
      unit in (
        'backup-root.service',
        'fstrim.service',
        'nix-gc.service',
        'yt-music-dl.service',
        'zpool-trim.service'
      )
    )
  ) or (
    e['PRIORITY'] >= LOG_INFO and (
      re.match(r'zfs-snapshot-\w+\.service', unit)
      or unit == 'systemd-tmpfiles-clean.service'
    )
  )