#!/usr/bin/env python

from collections import defaultdict, Counter
import json
import re
import base64
import argparse

import requests


def sizeof_fmt(num, suffix="B"):
  for unit in ["", "Ki", "Mi", "Gi", "Ti", "Pi", "Ei", "Zi"]:
    if abs(num) < 1024.0:
      return f"{num:3.1f}{unit}{suffix}"
    num /= 1024.0
  return f"{num:.1f}Yi{suffix}"


def check_positive(value):
  ivalue = int(value)
  if ivalue <= 0:
    raise argparse.ArgumentTypeError(f'{value} is an invalid positive int value')
  return ivalue


def cleanup(torrents, tag, target_size):
  candidates = {
    k: t
    for k, t in torrents.items()
    if 'recentUpTotal' in t and t['percentComplete'] == 100
  }
  total_size = sum(t['sizeBytes'] for t in torrents.values())
  candidate_size = sum(t['sizeBytes'] for t in candidates.values())
  need_to_free = total_size - target_size

  print(
    f'Total size of tag {tag!r}={sizeof_fmt(total_size)}',
    f'cleanable={sizeof_fmt(candidate_size)}',
    f'target={sizeof_fmt(target_size)}',
    f'to_free={sizeof_fmt(max(0, need_to_free))}',
  )
  if total_size < target_size:
    return

  if candidate_size < need_to_free:
    print(
      f'<3>Can\'t find enough items to delete for tag {tag!r}!',
      f'Want to free {sizeof_fmt(need_to_free)} but can only free {sizeof_fmt(candidate_size)}'
    )
  if not candidates:
    return

  for k, t in candidates.items():
    recentUp = t['recentUpTotal']
    sizeMiB = t['sizeBytes'] / (1024 * 1024)
    # add recent upload to prefer keeping active torrents
    # size^1.5 to prefer keeping smaller torrents (use MiB to prevent scores being too small)
    # then scale by how much upload was recent (plus an offset to prevent scores from being 0)
    t['score'] = (t['upTotal'] + recentUp * 2) / sizeMiB**1.5 * (recentUp / (t['upTotal'] + 1) + 0.5)

  by_score = sorted(candidates.keys(), key=lambda k: candidates[k]['score'])

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
    delta_up = t['recentUpTotal']
    print(
      f'{k}',
      f'{t["name"]}',
      f'size={sizeof_fmt(t["sizeBytes"])}',
      f'ratio={round(t["ratio"], 2)}',
      f'up={sizeof_fmt(t["upTotal"])}',
      f'Δratio={round(delta_up / t["sizeBytes"], 2)}',
      f'Δup={sizeof_fmt(delta_up)}',
      f'score={t["score"]}',
    )

  r = session.post(
    f'{base_url}/api/torrents/delete',
    json={
      'hashes': to_clean,
      'deleteData': True
    }
  )
  if r.status_code != 200:
    print(f'<3>Failed to delete torrents: {r.text}')


parser = argparse.ArgumentParser()
parser.add_argument('tag')
parser.add_argument('target', metavar='GiB-target', type=check_positive)
parser.add_argument('--n', default=24, type=check_positive)
args = parser.parse_args()

STATS_FILE = f'lastStats-{args.tag}.json'

with open('/var/lib/secrets/nginx-torrents/proxy-pw.conf') as f:
  auth = re.search('Authorization "Basic (.+?)"', f.read())[1]
  username, password = base64.b64decode(auth).decode('utf8').split(':')
base_url = 'http://192.168.1.2:13000'

session = requests.Session()
session.auth = (username, password)

r = session.get(f'{base_url}/api/auth/verify')
assert r.status_code == 200

r = session.get(f'{base_url}/api/torrents')
assert r.status_code == 200, f'Getting torrents returned status code: {r.status_code}'
torrents = json.loads(r.text)['torrents']

torrents = {k: t for k, t in torrents.items() if args.tag in t['tags']}

last_stats = defaultdict(list)
try:
  with open(STATS_FILE) as f:
    last_stats.update(json.load(f))
except FileNotFoundError:
  pass

# delete old entries
for k in list(last_stats.keys()):
  if k not in torrents:
    del last_stats[k]

# update stats
age_dist = Counter()
for k, t in torrents.items():
  stats = last_stats[k]
  stats.append(t['upTotal'])
  stat_count = len(stats)
  age_dist[stat_count] += 1

  i = stat_count - args.n
  if i <= 0:
    continue
  overflow, last_stats[k] = stats[:i], stats[i:]
  t['recentUpTotal'] = overflow[-1]

print(
  f'Age distribution ({args.tag!r}):',
  *(f'{age}: {count}' for age, count in sorted(age_dist.items(), reverse=True)),
  sep='\n'
)

cleanup(
  torrents,
  args.tag,
  args.target * 1024 * 1024 * 1024,
)

with open(STATS_FILE, 'w') as f:
  json.dump(last_stats, f)
