import re

from bepis_bot.runtime import require


core = require('core')
my_send_message = lambda content: core.send_message('hath_dl_done', content)
systemd_plug = require('systemd')


def on_journal_msg(e):
  if e.get('_SYSTEMD_UNIT') != 'hath.service':
    return
  message = e.get('MESSAGE', '')
  if not re.search(r'GalleryDownloader: Download thread finished.$', message):
    return
  my_send_message('Download thread finished')


systemd_plug.add_handler('hath_dl_done', on_journal_msg)