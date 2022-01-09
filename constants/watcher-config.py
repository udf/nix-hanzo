import re
import os

owner = 232787997
token = os.environ['TOKEN']

flood_server_url = 'http://127.0.0.1:3000'

def systemd_should_ignore(e):
  source = e.get('_COMM') or e.get('SYSLOG_IDENTIFIER')
  if source == 'kernel':
    return e['PRIORITY'] >= 6
  if source != 'systemd':
    # ignore non-systemd notice and below
    return e['PRIORITY'] >= 5

  unit = e.get('UNIT', '')
  return (
    e['PRIORITY'] >= 5 and (
      unit == 'backup-root.service'
    )
  ) or (
    e['PRIORITY'] >= 6 and (
      re.match(r'zfs-snapshot-\w+\.service', unit)
      or unit == 'systemd-tmpfiles-clean.service'
    )
  )