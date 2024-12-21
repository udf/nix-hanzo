import os
import json
import argparse

from google_auth_oauthlib.flow import InstalledAppFlow
from google.oauth2.credentials import Credentials
from google.auth.transport.requests import Request
import googleapiclient.discovery
import googleapiclient.errors

SCOPES = ['https://www.googleapis.com/auth/youtube.readonly']


def get_saved_credentials(filename):
  fileData = {}
  try:
    with open(filename, 'r') as file:
      fileData: dict = json.load(file)
  except FileNotFoundError:
    return None
  return Credentials(**fileData)


def store_creds(credentials, filename):
  fileData = {
    'refresh_token': credentials.refresh_token,
    'token': credentials.token,
    'client_id': credentials.client_id,
    'client_secret': credentials.client_secret,
    'token_uri': credentials.token_uri
  }
  with open(filename, 'w') as file:
      json.dump(fileData, file)
  print(f'Credentials serialized to {filename}.')


def get_credentials_via_oauth(client_secret_path, client_credentials_path, saveData=True):
  iaflow = InstalledAppFlow.from_client_secrets_file(client_secret_path, SCOPES)
  iaflow.run_local_server()
  if saveData:
    store_creds(iaflow.credentials, filename=client_credentials_path)
  return iaflow.credentials


parser = argparse.ArgumentParser()
parser.add_argument('--out-path', required=True)
parser.add_argument('--client-secret-path', required=True)
parser.add_argument('--client-credentials-path', required=True)
args = parser.parse_args()

# Disable OAuthlib's HTTPS verification when running locally.
# *DO NOT* leave this option enabled in production.
os.environ['OAUTHLIB_INSECURE_TRANSPORT'] = '1'

credentials = get_saved_credentials(args.client_credentials_path)
if credentials and credentials.expired:
  credentials.refresh(Request())
if not credentials or not credentials.valid:
  credentials = get_credentials_via_oauth(
    client_secret_path=args.client_secret_path,
    client_credentials_path=args.client_credentials_path
  )
youtube = googleapiclient.discovery.build('youtube', 'v3', credentials=credentials)

next_page_token = None
video_ids = []
while 1:
  request = youtube.playlistItems().list(
    playlistId='PLjgVd_07uAd9ZB-rifTujZ604jYTT68-4',
    part='contentDetails',
    maxResults=50,
    pageToken=next_page_token
  )
  response = request.execute()

  for item in response.get('items', []):
    video_id = item.get('contentDetails', {}).get('videoId')
    if video_id:
      video_ids.append(video_id)

  next_page_token = response.get('nextPageToken')
  if not next_page_token:
    break

new_list = '\n'.join(video_ids)
old_list = ''
try:
  with open(args.out_path) as f:
    old_list = f.read()
except FileNotFoundError:
  pass

if old_list == new_list:
  print('no new video IDs')
  exit()

with open(args.out_path, 'w') as f:
  f.write(new_list)
print(f'grabbed {len(video_ids)} video IDs')
