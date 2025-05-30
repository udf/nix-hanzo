import argparse
import shutil
from pathlib import Path
from datetime import datetime, timezone

from common import find_video_files, sizeof_fmt


parser = argparse.ArgumentParser()
parser.add_argument('--trash-dir', required=True)
parser.add_argument('--min-free-gb', required=True, type=int)
parser.add_argument('--warn-free-gb', required=True, type=int)

args = parser.parse_args()
trash_dir = Path(args.trash_dir)

gb_bytes = 1024 * 1024 * 1024
min_free_bytes = args.min_free_gb * gb_bytes
total, used, free = shutil.disk_usage(trash_dir)
print(f'{sizeof_fmt(free)} free')
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

print(f'Need to free {sizeof_fmt(min_free_bytes - free)}!')
while free < min_free_bytes and trash_by_date:
  path = trash_by_date.pop()
  f_stat = path.stat()
  m_time_str = (
    datetime
    .fromtimestamp(f_stat.st_mtime, timezone.utc)
    .astimezone()
    .replace(microsecond=0)
    .isoformat()
  )
  print(f'Deleting {str(path)!r} ({sizeof_fmt(f_stat.st_size)}, {m_time_str})')
  path.unlink()
  free += f_stat.st_size

total, used, free = shutil.disk_usage(trash_dir)
print(f'{sizeof_fmt(free)} free after cleaning')
if free < args.warn_free_gb * gb_bytes:
  print(f'<1>Not enough free space after cleaning!')