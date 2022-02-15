#!/usr/bin/env python
import json
import os
from pathlib import Path
import r128gain
import logging

logging.basicConfig(level=logging.INFO)
PATHS_FILE = 'paths.json'


def walk_files(path):
  for root, dirs, files in os.walk(path):
    root = Path(root)
    for file in files:
      yield root / file


def get_identifier(path: Path):
  # maybe use size too
  return path.stat().st_mtime


old_paths = {}
try:
  with open(PATHS_FILE) as f:
    old_paths = json.load(f)
except FileNotFoundError:
  pass

in_paths = {str(f): get_identifier(f) for f in walk_files('.') if r128gain.is_audio_filepath(f)}
print(f'Found {len(in_paths)} files')
# prune deleted paths
old_paths = {f: t for f, t in old_paths.items() if f in in_paths}
# only process paths that changed or are new
in_paths = {f: t for f, t in in_paths.items() if old_paths.get(f) != t}
print(f'Tagging {len(in_paths)} files')

err_count = r128gain.process(in_paths)
in_paths = {f: get_identifier(Path(f)) for f, t in in_paths.items()}

with open(PATHS_FILE, 'w') as f:
  json.dump(old_paths | in_paths, f)

if err_count > 0:
  exit(1)