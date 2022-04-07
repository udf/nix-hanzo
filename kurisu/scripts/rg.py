#!/usr/bin/env python
import json
import os
from pathlib import Path
import r128gain
import logging
import mutagen

logging.basicConfig(level=logging.INFO)
PATHS_FILE = 'paths.json'
fprint = lambda *args, **kwargs: print(*args, flush=True, **kwargs)

remove_tags = [
  'replaygain_album_gain',
  'replaygain_album_peak',
  'replaygain_reference_loudness',
  'replaygain_album_range',
  'replaygain_track_range',
]


def walk_files(path):
  for root, dirs, files in os.walk(path):
    root = Path(root)
    for file in files:
      yield root / file


def get_identifier(path: Path):
  # maybe use size too
  return path.stat().st_mtime


def clean_tags(path):
  mf = mutagen.File(path)
  modified = False

  for t in remove_tags:
    if t in mf:
      del mf[t]
      modified = True

  if not modified:
    return False
  fprint(f'Cleaned {path}')
  mf.save()
  return True


old_paths = {}
try:
  with open(PATHS_FILE) as f:
    old_paths = json.load(f)
except FileNotFoundError:
  pass

in_paths = {str(f): get_identifier(f) for f in walk_files('.') if r128gain.is_audio_filepath(f)}
fprint(f'<4>Found {len(in_paths)} files')
# prune deleted paths
old_paths = {f: t for f, t in old_paths.items() if f in in_paths}
# only process paths that changed or are new
in_paths = {f: t for f, t in in_paths.items() if old_paths.get(f) != t}
fprint(f'<4>Tagging {len(in_paths)} files')

num_cleaned = sum(clean_tags(f) for f in in_paths.keys())
if num_cleaned:
  fprint(f'<4>Cleaned {num_cleaned} path(s)')

err_count = r128gain.process(in_paths)
in_paths = {f: get_identifier(Path(f)) for f, t in in_paths.items()}

with open(PATHS_FILE, 'w') as f:
  json.dump(old_paths | in_paths, f)

if err_count > 0:
  exit(1)