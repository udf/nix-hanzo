import re
import os

from datetime import datetime, timezone
from telethon import events
import pyasn

from bepis_bot.runtime import client, config, logger, require


core = require('core')
my_send_message = lambda content: core.send_message('szuru_ip', content)
systemd_plug = require('systemd')
seen_ips = {}

asndb = pyasn.pyasn(
  os.environ['IPASN_DB'],
  as_names_file=os.environ['ASNAMES_JSON']
)


def lookup_ip(ip):
  asn, prefix = asndb.lookup(ip)
  asname = asndb.get_as_name(asn)
  ip_str = [f'<code>{ip}</code>']
  if prefix:
    ip_str.append(f'[<code>{prefix}</code>]')
  if asn:
    ip_str.append(f'<code>AS{asn}</code>')
  if asname:
    ip_str.append(f'(<code>{asname}</code>)')
  return ' '.join(ip_str)


@client.on(events.NewMessage(chats=config.owner, pattern='/szuru_ips$'))
async def get_seen_ips(event):
  message = []
  for ip, timestamp in sorted(seen_ips.items(), key=lambda x: x[1], reverse=True):
    dt = datetime.fromtimestamp(timestamp, tz=timezone.utc)
    message.append(f'<code>{dt.strftime("%A, %-d %b %Y %H:%M:%S %Z")}</code>: {lookup_ip(ip)}')
  my_send_message('\n'.join(message) if message else 'No recently seen IPs!')


def on_journal_msg(e):
  if e.get('_SYSTEMD_UNIT') != 'szuru.service':
    return

  message = e.get('MESSAGE', '')
  ip = re.match(r'^client.+ (\d+\.\d+\.\d+\.\d+)$', message)
  if not ip or ip[1] in seen_ips:
    return
  ip = ip[1]
  seen_ips[ip] = datetime.now(timezone.utc).timestamp()
  my_send_message(f'🚨🚨🚨\nSpotted new IP: {lookup_ip(ip)}')


systemd_plug.add_handler('szuru_ip', on_journal_msg)