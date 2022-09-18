#!/usr/bin/env python

import json
import re
import base64

import requests


def sizeof_fmt(num, suffix="B"):
  for unit in ["", "Ki", "Mi", "Gi", "Ti", "Pi", "Ei", "Zi"]:
    if abs(num) < 1024.0:
      return f"{num:3.1f}{unit}{suffix}"
    num /= 1024.0
  return f"{num:.1f}Yi{suffix}"


def cleanup(torrents, tag, last_stats, target_size):
  candidates = {k: v for k, v in torrents.items() if tag in v['tags']}
  total_size = sum(t['sizeBytes'] for t in candidates.values())

  if total_size < target_size:
    print(f'Total size of tag {tag!r}={sizeof_fmt(total_size)} target={sizeof_fmt(target_size)}')
    return

  candidates = {k: v for k, v in candidates.items() if v['percentComplete'] == 100}
  s = sorted(((k, (v['upTotal'] - last_stats.get(k, 0)) / (v['sizeBytes'] / 1024 / 1024)**2) for k, v in candidates.items()), key=lambda v: v[1])

  need_to_free = total_size - target_size
  total_cleaned = 0
  to_clean = []
  for k, score in s:
    total_cleaned += candidates[k]['sizeBytes']
    to_clean.append(k)
    if total_cleaned >= need_to_free:
      break

  print(f'Deleting {len(to_clean)} torrents with tag {tag!r}')
  for k in to_clean:
    t = candidates[k]
    delta_up = (t['upTotal'] - last_stats.get(k, 0))
    print(
      f'{t["name"]} '
      f'size={sizeof_fmt(t["sizeBytes"])} '
      f'ratio={round(t["ratio"], 2)} '
      f'up={sizeof_fmt(t["upTotal"])} '
      f'Δratio={round(delta_up / t["sizeBytes"], 2)} '
      f'Δup={sizeof_fmt(delta_up)}'
    )

  r = session.post(
    f'{base_url}/api/torrents/delete',
    data={
      'hashes': to_clean,
      'deleteData': True
    }
  )
  if r.status_code != 200:
    print(f'<3>Failed to delete torrents: {r.text}')


with open('/var/lib/secrets/nginx-torrents/proxy-pw.conf') as f:
  auth = re.search('Authorization "Basic (.+?)"', f.read())[1]
  username, password = base64.b64decode(auth).decode('utf8').split(':')
base_url = 'http://192.168.1.2:13000'

session = requests.Session()
session.auth = (username, password)

r = session.get(f'{base_url}/api/auth/verify')
assert r.status_code == 200

r = session.get(f'{base_url}/api/torrents')
torrents = json.loads(r.text)['torrents']

try:
  with open('lastStats.json') as f:
    last_stats = json.load(f)
except FileNotFoundError:
  last_stats = {}

cleanup(torrents, 'seed', last_stats, 500 * 1024 * 1024 * 1024)
cleanup(torrents, 'RSS', last_stats, 250 * 1024 * 1024 * 1024)

with open('lastStats.json', 'w') as f:
  json.dump({k: v['upTotal'] for k, v in torrents.items()}, f)