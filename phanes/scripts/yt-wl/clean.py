import argparse
import os
import re
import shutil
import time
from pathlib import Path

from common import find_video_files


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

# trash/delete unwanted ids
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