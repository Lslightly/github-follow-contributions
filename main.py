from github.NamedUser import NamedUser
import yaml

from tqdm import tqdm

from datetime import datetime, timedelta
import json
import os

from mytyping import *  # noqa: F403
from config import *  # noqa: F403
import event_analysis

def get_following_users() -> List[NamedUser]:
    following_plist = Me.get_following()
    res = [user for user in following_plist]
    res.insert(0, typing.cast(NamedUser, GH.get_user(Me.login)))
    return res

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
    events.sort(key=lambda e: e.created_at, reverse=True)
    return events

def deduplicate_list(lst):
    return [x for i, x in enumerate(lst) if x not in lst[:i]]

def get_all_events(users: List[NamedUser]):
    print(f"Found {len(users)} followed users")

    # event: (repo, type)
    # events: list[event]
    # user_events: dict[user, events]
    # all_events: list[user_events]
    all_events: list[dict[str, Any]] = []
    for user in tqdm(users[:]):
        user_login = user.login
        tqdm.write(f"Processing user: {user_login}")
        events = get_user_events(user)
        tqdm.write(f"Events Num: {len(events)}")
        # topics = event_analysis.DEFAULT_TOPICS
        repo_et_payload = [(event.repo.name, event.type, event.payload) for event in events]
        repo_et_payload = deduplicate_list(repo_et_payload)
        topics = event_analysis.summarize_topics(events[:SUMMARY_EVENT_LIMIT])
        user_events = {
            "username": user_login,
            "events": repo_et_payload,
            "summary_topics": topics,
        }
        tqdm.write(f"len(events): {len(events)}, len(topics): {len(topics)}")
        all_events.append(user_events)

    return all_events


if __name__ == '__main__':
    following = get_following_users()
    dump_following(following)
    special = filter_special(following)
    events = get_all_events(special)
    os.makedirs("public", exist_ok=True)
    with open('public/events.json', 'w') as f:
        json.dump(events, f)
