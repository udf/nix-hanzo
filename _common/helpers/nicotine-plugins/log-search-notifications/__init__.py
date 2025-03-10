from pynicotine.pluginsystem import BasePlugin
from pynicotine.events import events


class Plugin(BasePlugin):
  def __init__(self, *args, **kwargs):
    super().__init__(*args, **kwargs)
    events.connect('show-search-notification', self.on_show_search_notification)

  def disable(self):
    events.disconnect('show-search-notification', self.on_show_search_notification)

  def on_show_search_notification(self, search_token, message, title=None):
    print(f'<4>Wishlist result found:\n{message}')
