from pynicotine.pluginsystem import BasePlugin
from pynicotine.events import events


class Plugin(BasePlugin):
  def __init__(self, *args, **kwargs):
    super().__init__(*args, **kwargs)

    self.event_handlers = (
      ('show-search-notification', self.on_show_search_notification),
      ('show-download-notification', self.on_show_download_notification),
    )

    for event_name, func in self.event_handlers:
      events.connect(event_name, func)

  def disable(self):
    for event_name, func in self.event_handlers:
      events.disconnect(event_name, func)

  def on_show_search_notification(self, search_token, message, title=None):
    print(f'<4>{title}: {message}')

  def on_show_download_notification(self, message, title=None, high_priority=False):
    print(f'<4>{title}: {message}')
