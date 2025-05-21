import re
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


def sizeof_fmt(num: int, suffix="B"):
  for unit in ("", "Ki", "Mi", "Gi", "Ti", "Pi", "Ei", "Zi"):
    if abs(num) < 1024.0:
      return f"{num:3.1f}{unit}{suffix}"
    num /= 1024.0
  return f"{num:.1f}Yi{suffix}"
