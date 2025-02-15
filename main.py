import github
import argparse
from github.PaginatedList import PaginatedList
from github.AuthenticatedUser import AuthenticatedUser
from github.NamedUser import NamedUser
import yaml

from tqdm import tqdm

import typing
from typing import List

import requests
from datetime import datetime, timedelta
import time
import json
import os

PAGE_LIMIT = 10
DAYS_AGO = 30

def print_help():
    print('Usage: GITHUB_TOKEN=your_token python main.py [OPTIONS]')

GITHUB_TOKEN = os.getenv('GITHUB_TOKEN')
if not GITHUB_TOKEN:
    print_help()
    exit(1)

HEADERS = {'Authorization': f'token {GITHUB_TOKEN}'}
GH = github.Github(auth=github.Auth.Token(GITHUB_TOKEN))
Me = typing.cast(AuthenticatedUser, GH.get_user())
SPECIAL_YAML = "special.yaml"
ALL_YAML = "all.yaml"

def get_following_users() -> List[NamedUser]:
    following_plist = Me.get_following()
    return [user for user in following_plist]

def dump_following(users: List[NamedUser]):
    all_logins = [user.login for user in users]
    with open(ALL_YAML, "w") as f:
        yaml.safe_dump(all_logins, f)

def filter_special(users: List[NamedUser]) -> List[NamedUser]:
    if os.path.exists(SPECIAL_YAML): # use special yaml
        with open(SPECIAL_YAML, "r") as f:
            special_user_logins = yaml.safe_load(f)
            users = list(filter(lambda user: user.login in special_user_logins, users))
    return users
        

def filter_date(t: datetime):
    t = t.replace(tzinfo=None)
    time_limit = datetime.now() - timedelta(days=DAYS_AGO)
    return t >= time_limit

def get_user_events(user: NamedUser):
    events_plist = user.get_events()
    events = [event for event in events_plist if filter_date(event.created_at)]
    return events

def deduplicate_list(lst):
    return [x for i, x in enumerate(lst) if x not in lst[:i]]

def get_all_events(users: List[NamedUser]):
    print(f"Found {len(users)} followed users")

    # event: (repo, type)
    # events: list[event]
    # user_events: dict[user, events]
    # all_events: list[user_events]
    all_events: list[dict[str, list[tuple[str, str]]]] = []
    for user in tqdm(users):
        user_login = user.login
        tqdm.write(f"Processing user: {user_login}")
        events = get_user_events(user)
        events = [(event.repo.name, event.type) for event in events]
        events = deduplicate_list(events)
        user_events = {user_login: events}
        all_events.append(user_events)

    return all_events


if __name__ == '__main__':
    following = get_following_users()
    dump_following(following)
    special = filter_special(following)
    events = get_all_events(special)
    with open('events.json', 'w') as f:
        json.dump(events, f)
