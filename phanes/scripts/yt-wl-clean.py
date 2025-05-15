import argparse
import os
import re
import shutil
import time
from collections import defaultdict
from pathlib import Path


def find_video_files(src_dir: Path):
  vids_by_id: defaultdict[str, list[Path]] = defaultdict(list)
  extra_files: list[Path] = []
  for path in src_dir.rglob('*.*', recurse_symlinks=False):
    if not path.is_file():
      continue
    vidID = re.search(r'\[([\dA-Za-z_-]{11})\]$', path.stem)
    if not vidID:
      extra_files.append(path)
      continue
    vids_by_id[vidID.group(1)].append(path)
  return vids_by_id, extra_files


def move_mkdir(src: Path, dst: Path, log_prefix='Moving'):
  print(f'{log_prefix} {str(src)!r} -> {str(dst)!r}')
  dst.parent.mkdir(parents=True, exist_ok=True)
  shutil.move(src, dst)
  os.utime(dst, (now, now))


parser = argparse.ArgumentParser()
parser.add_argument('--download-dir', required=True)
parser.add_argument('--download-list', required=True)
parser.add_argument('--trash-dir', required=True)
parser.add_argument('--trash-filter-re', required=True)
parser.add_argument('--delete-filter-re', required=True)
parser.add_argument('--min-free-gb', required=True, type=int)
args = parser.parse_args()

download_dir = Path(args.download_dir)
download_list = Path(args.download_list)
trash_dir = Path(args.trash_dir)
trash_filter_re = re.compile(args.trash_filter_re)
delete_filter_re = re.compile(args.delete_filter_re)

expected_ids = set()
with open(download_list) as f:
  for line in f:
    expected_ids.add(line.strip())

# trash unwanted ids
now = time.time()
downloads_by_id, _ = find_video_files(download_dir)
for vidID in set(downloads_by_id.keys()) - expected_ids:
  for path in downloads_by_id[vidID]:
    rel_path = path.relative_to(download_dir)
    if trash_filter_re.match(str(rel_path)):
      move_mkdir(path, trash_dir / rel_path, 'Trashing')
      continue
    if delete_filter_re.match(str(rel_path)):
      print(f'Deleting {str(path)!r}')
      path.unlink()
downloads_by_id = None

# restore wanted ids from trash
trash_by_id, _ = find_video_files(trash_dir)
for vidID in set(trash_by_id.keys()) & expected_ids:
  for path in trash_by_id[vidID]:
    move_mkdir(
      src=path,
      dst=download_dir / path.relative_to(trash_dir),
      log_prefix='Restoring'
    )


gb_bytes = 1024 * 1024 * 1024
min_free_bytes = args.min_free_gb * gb_bytes
total, used, free = shutil.disk_usage(trash_dir)
print(f'{free / gb_bytes:.2f} GB free')
if free > min_free_bytes:
  exit()

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