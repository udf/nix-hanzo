import os
import time
import re
from collections import defaultdict, namedtuple

from pynicotine.pluginsystem import BasePlugin
from pynicotine.events import events
from pynicotine.search import SearchRequest
from pynicotine.slskmessages import FileSearchResponse


# time (in seconds) before making a new browse request to the same user
REBROWSE_TIME = 1 * 60 * 60
# time (in seconds) to check if pending browse requests succeeded
RETRY_TIME = 30
# number of times to retry before giving up
MAX_RETRIES = 10
# [pipe, ampersand, comma, semicolon, space]
FILTER_SPLIT_TEXT_PATTERN = re.compile(r'(?:[|&,;\s])+(?<!!\s)')

PendingRequest = namedtuple('PendingRequest', ['expiry_time', 'path', 'attempts'], defaults=(0, '', 1))


class Plugin(BasePlugin):
  def __init__(self, *args, **kwargs):
    super().__init__(*args, **kwargs)
    self.last_browse_time = defaultdict(float)
    self.pending_browse_requests: dict[str, PendingRequest] = {}

    type_filter = self.config.sections['searches']['defilter'][6]
    self.allowed_types = set(
      s for s in
      FILTER_SPLIT_TEXT_PATTERN.split(type_filter)
      if s and s[0] != '!'
    )
    self.log(f'Filetype filter: {repr(self.allowed_types)}')

    self.event_handlers = (
      ('file-search-response', self.on_file_search_response),
      ('shared-file-list-progress', self.on_shared_file_list_progress),
      ('shared-file-list-response', self.on_shared_file_list_response),
    )

    for event_name, func in self.event_handlers:
      events.connect(event_name, func)

    self.scheduled_events = [
      events.schedule(delay=31, callback=self.check_pending_requests, repeat=True)
    ]

  def disable(self):
    for event_name, func in self.event_handlers:
      events.disconnect(event_name, func)
    for event_id in self.scheduled_events:
      events.cancel_scheduled(event_id)

  def browse_user(self, user, path):
    current_time = time.monotonic()
    new_request = current_time - self.last_browse_time[user] >= REBROWSE_TIME
    self.last_browse_time[user] = current_time

    self.core.userbrowse.browse_user(
      user,
      path=path,
      new_request=new_request,
      switch_page=False
    )

    if new_request:
      self.pending_browse_requests[user] = PendingRequest(current_time + RETRY_TIME, path)

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
    events.schedule(delay=10, callback=self.browse_user, callback_args=(user, first_path))

  def reset_request_timeout(self, username, retry=False):
    if req := self.pending_browse_requests.get(username):
      self.pending_browse_requests[username] = req._replace(
        expiry_time=time.monotonic() + RETRY_TIME,
        attempts=req.attempts + 1 if retry else req.attempts
      )

  def check_pending_requests(self):
    for user, req in self.pending_browse_requests.items():
      current_time = time.monotonic()
      if req.expiry_time > current_time:
        continue
      # timeout reached, retry
      if req.attempts >= MAX_RETRIES:
        self.log(f'Reached max retries browsing {user}\'s shares, giving up')
        self.pending_browse_requests.pop(user, None)
        continue
      self.log(f'Timed out browsing {user}\'s shares, retrying (attempt {req.attempts + 1})...')
      self.core.userbrowse.browse_user(
        user,
        path=req.path,
        new_request=True,
        switch_page=False
      )
      self.reset_request_timeout(user)

  def on_shared_file_list_progress(self, username, sock, _buffer_len, _msg_size_total):
    self.reset_request_timeout(username)

  def on_shared_file_list_response(self, msg):
    self.pending_browse_requests.pop(msg.username, None)
