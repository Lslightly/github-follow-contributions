import github
from github.AuthenticatedUser import AuthenticatedUser
import os
from dotenv import load_dotenv
load_dotenv()

from mytyping import *  # noqa: F403

PAGE_LIMIT = 10
DAYS_AGO = 20
SUMMARY_EVENT_LIMIT = 30

def print_help():
    print('Usage: GH_TOKEN=your_token python main.py [OPTIONS]')

GH_TOKEN = os.getenv('GH_TOKEN')
if not GH_TOKEN:
    print_help()
    exit(1)

HEADERS = {'Authorization': f'token {GH_TOKEN}'}
GH = github.Github(auth=github.Auth.Token(GH_TOKEN))
Me = typing.cast(AuthenticatedUser, GH.get_user())
SPECIAL_YAML = "special.yaml"
ALL_YAML = "all.yaml"