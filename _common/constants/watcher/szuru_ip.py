import re
import os

import pyasn

from bepis_bot.runtime import config, logger, require


core = require('core')
systemd_plug = require('systemd')
seen_ips = set()

asndb = pyasn.pyasn(
  os.environ['IPASN_DB'],
  as_names_file=os.environ['ASNAMES_JSON']
)

def on_journal_msg(e):
  if e.get('_SYSTEMD_UNIT') != 'szuru.service':
    return

  message = e.get('MESSAGE', '')
  ip = re.match(r'^client.+ (\d+\.\d+\.\d+\.\d+)$', message)
  if not ip or ip[1] in seen_ips:
    return
  ip = ip[1]
  seen_ips.add(ip)
  asn, prefix = asndb.lookup(ip)
  asname = asndb.get_as_name(asn)
  message = [f'🚨🚨🚨\nSpotted new IP: {ip}']
  if prefix:
    message.append(f'[{prefix}]')
  if asn:
    message.append(f'AS{asn}')
  if asname:
    message.append(f'({asname})')
  core.send_message('szuru_ip', ' '.join(message))


systemd_plug.add_handler('szuru_ip', on_journal_msg)