import signal

from pynicotine.pluginsystem import BasePlugin
from pynicotine.events import events


class Plugin(BasePlugin):
  def __init__(self, *args, **kwargs):
    super().__init__(*args, **kwargs)
    self.rescan_queued = False
    self._orig_usr1_handler = signal.getsignal(signal.SIGUSR1)
    signal.signal(signal.SIGUSR1, self.rescan_shares)
    events.connect('shares-ready', self.shares_ready)

  def disable(self):
    signal.signal(signal.SIGUSR1, self._orig_usr1_handler)
    events.disconnect('shares-ready', self.shares_ready)

  def _log(self, msg, only_print=False):
    if not only_print:
      self.log(msg)
    print(f'<4>{msg}')

  def rescan_shares(self, sig, frame):
    if self.core.shares.rescanning:
      self._log('Scan currently in progress, queuing new scan...')
      self.rescan_queued = True
      return
    self._log('Rescanning shares...')
    self.core.shares.rescan_shares()

  def shares_ready(self, successful):
    if self.rescan_queued:
      self._log('Rescanning shares (queued)...')
      self.rescan_queued = False
      self.core.shares.rescan_shares()
      return
    self._log('Share rescan complete!', only_print=True)