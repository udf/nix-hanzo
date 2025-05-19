import argparse
import shutil
from pathlib import Path

from common import find_video_files


parser = argparse.ArgumentParser()
parser.add_argument('--trash-dir', required=True)
parser.add_argument('--min-free-gb', required=True, type=int)

args = parser.parse_args()
trash_dir = Path(args.trash_dir)

gb_bytes = 1024 * 1024 * 1024
min_free_bytes = args.min_free_gb * gb_bytes
total, used, free = shutil.disk_usage(trash_dir)
print(f'{free / gb_bytes:.2f} GB free')
if free > min_free_bytes:
  exit()

trash_by_id, _ = find_video_files(trash_dir)
trash_by_date = sorted(
  (
    path
    for paths in trash_by_id.values()
    for path in paths
  ),
  key=lambda f: f.stat().st_mtime,
  reverse=True
)

print(f'Need to free {(min_free_bytes - free) / gb_bytes:.2f} GB!')
while free < min_free_bytes and trash_by_date:
  path = trash_by_date.pop()
  f_size = path.stat().st_size
  print(f'Deleting {str(path)!r}')
  path.unlink()
  free += f_size

total, used, free = shutil.disk_usage(trash_dir)
print(f'{free / gb_bytes:.2f} GB free after cleaning')
if free < min_free_bytes:
  print(f'<1>Not enough free space after cleaning!')