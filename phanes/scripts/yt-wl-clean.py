import argparse
import os
import re
import shutil
import time
from pathlib import Path


parser = argparse.ArgumentParser()
parser.add_argument('--download-dir', required=True)
parser.add_argument('--trash-dir', required=True)
parser.add_argument('--min-free-gb', required=True, type=int)
args = parser.parse_args()

download_dir = Path(args.download_dir)
os.chdir(download_dir)
trash_dir = Path(args.trash_dir)
vid_dirs = [
  (True, download_dir / 'wl'),
  (False, download_dir / 'wl_720')
]

expected_ids = set()
with open('wl.txt') as f:
  for line in f:
    expected_ids.add(line.strip())

now = time.time()
for use_trash, dir_name in vid_dirs:
  for path in Path(dir_name).glob('*.*'):
    vidID = re.search(r' \[([\dA-Za-z_-]{11})\]\.', path.name)
    if not vidID:
      continue
    vidID = vidID[1]
    if vidID in expected_ids:
      continue
    if use_trash:
      print(f'Trashing {str(path)!r}')
      new_path = trash_dir / path.relative_to(download_dir)
      new_path.parent.mkdir(parents=True, exist_ok=True)
      shutil.move(path, new_path)
      os.utime(new_path, (now, now))
    else:
      print(f'Deleting {str(path)!r}')
      path.unlink()

gb_bytes = 1024 * 1024 * 1024
min_free_gb = args.min_free_gb * gb_bytes
total, used, free = shutil.disk_usage(trash_dir)
print(f'{free / gb_bytes:.2f} GB free')
if free > min_free_gb:
  exit()

trash_by_date = sorted(
  (
    f for f in trash_dir.rglob('*.*', recurse_symlinks=False)
    if f.is_file(follow_symlinks=False)
  ),
  key=lambda f: f.stat().st_mtime,
  reverse=True
)

print(f'Need to free {(min_free_gb - free) / gb_bytes:.2f} GB!')
while free < min_free_gb and trash_by_date:
  path = trash_by_date.pop()
  f_size = path.stat().st_size
  print(f'Deleting {str(path)!r}')
  path.unlink()
  free += f_size

total, used, free = shutil.disk_usage(trash_dir)
print(f'{free / gb_bytes:.2f} GB free after cleaning')