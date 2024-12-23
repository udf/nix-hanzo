import argparse
import os
import re
import shutil
import time
from pathlib import Path


parser = argparse.ArgumentParser()
parser.add_argument('--download-dir', required=True)
parser.add_argument('--trash-dir', required=True)
args = parser.parse_args()

download_dir = Path(args.download_dir)
os.chdir(download_dir)
trash_dir = Path(args.trash_dir)
vid_dirs = [
  download_dir / 'wl',
  download_dir / 'wl_720'
]

expected_ids = set()
with open('wl.txt') as f:
  for line in f:
    expected_ids.add(line.strip())

now = time.time()
for dir_name in vid_dirs:
  for path in Path(dir_name).glob('*.*'):
    vidID = re.search(r' \[([\dA-Za-z_-]{11})\]\.', path.name)
    if not vidID:
      continue
    vidID = vidID[1]
    if vidID not in expected_ids:
      print(f'Trashing {str(path)!r}')
      new_path = trash_dir / path.relative_to(download_dir)
      new_path.parent.mkdir(parents=True, exist_ok=True)
      shutil.move(path, new_path)
      os.utime(new_path, (now, now))