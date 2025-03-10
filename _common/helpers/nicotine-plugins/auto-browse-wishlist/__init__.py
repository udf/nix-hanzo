import os
import time
import re
from collections import defaultdict

from pynicotine.pluginsystem import BasePlugin
from pynicotine.events import events
from pynicotine.search import SearchRequest
from pynicotine.slskmessages import FileSearchResponse


# time (in seconds) before making a new browse request to the same user
REBROWSE_TIME = 6 * 60 * 60
# [pipe, ampersand, comma, semicolon, space]
FILTER_SPLIT_TEXT_PATTERN = re.compile(r'(?:[|&,;\s])+(?<!!\s)')


class Plugin(BasePlugin):
  def __init__(self, *args, **kwargs):
    super().__init__(*args, **kwargs)
    self.last_browse_time = defaultdict(float)
    type_filter = self.config.sections['searches']['defilter'][6]
    self.allowed_types = set(
      s for s in
      FILTER_SPLIT_TEXT_PATTERN.split(type_filter)
      if s and s[0] != '!'
    )
    self.log(repr(self.allowed_types))
    events.connect('file-search-response', self.on_file_search_response)

  def disable(self):
    events.disconnect('file-search-response', self.on_file_search_response)

  def browse_user(self, user, path):
    self.core.userbrowse.browse_user(
      user,
      path=path,
      switch_page=False,
    )

  def on_file_search_response(self, msg: FileSearchResponse):
    search: SearchRequest = self.core.search.searches.get(msg.token)
    if not search or search.mode != 'wishlist':
      return

    first_path = None
    for _code, file_path, size, _ext, file_attributes, *_unused in (msg.list or []):
      file_path_lower = file_path.lower()
      _, ext = os.path.splitext(file_path_lower)
      ext = ext[1:]
      if self.allowed_types and ext not in self.allowed_types:
        continue
      if any(word in file_path_lower for word in (search.included_words or [])):
        first_path = file_path
        break

    if not first_path:
      return

    user = msg.username
    self.log(f'Browsing {user}\'s shares (for "{search.term}")')

    current_time = time.monotonic()
    self.core.userbrowse.browse_user(
      user,
      path=first_path,
      switch_page=False,
      new_request=current_time - self.last_browse_time[user] >= REBROWSE_TIME
    )
    self.last_browse_time[user] = current_time

    # sometimes the shares don't load on the first try, potentially resend the request after a minute
    events.schedule(delay=60, callback=self.browse_user, callback_args=(user, first_path))
