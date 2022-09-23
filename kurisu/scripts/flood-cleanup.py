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
  candidates = {k: t for k, t in torrents.items() if tag in t['tags'] and t['percentComplete'] == 100}
  total_size = sum(t['sizeBytes'] for t in candidates.values())

  if total_size < target_size:
    print(f'Total size of (completed) tag {tag!r}={sizeof_fmt(total_size)} target={sizeof_fmt(target_size)}')
    return

  for k, t in candidates.items():
    recentUp = t['upTotal'] - last_stats.get(k, 0)
    sizeMiB = t['sizeBytes'] / (1024 * 1024)
    # add recent upload to prefer keeping active torrents
    # size^2 to prefer keeping smaller torrents (use MiB to prevent scores being too small)
    # then scale by how much upload was recent (plus an offset to prevent scores from being 0)
    score = (t['upTotal'] + recentUp * 2) / sizeMiB**2 * (recentUp / (t['upTotal'] + 1) + 0.5)
    t['score'] = score

  # split based on ratio to prefer removing higher ratio first
  low_ratio = [k for k, t in candidates.items() if t['ratio'] < 2]
  high_ratio = [k for k, t in candidates.items() if t['ratio'] >= 2]

  low_ratio.sort(key=lambda k: candidates[k]['score'])
  high_ratio.sort(key=lambda k: candidates[k]['score'])
  by_score = high_ratio + low_ratio

  need_to_free = total_size - target_size
  total_cleaned = 0
  to_clean = []
  for k in by_score:
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
      f'Δup={sizeof_fmt(delta_up)} '
      f'score={t["score"]}'
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
cleanup(torrents, 'RSS', last_stats, 300 * 1024 * 1024 * 1024)

with open('lastStats.json', 'w') as f:
  json.dump({k: t['upTotal'] for k, t in torrents.items()}, f)
