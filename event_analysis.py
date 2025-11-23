from collections import defaultdict
from github.Event import Event
from github.Repository import Repository
import openai
import os

from tqdm import tqdm

from mytyping import *  # noqa: F403
from config import *  # noqa: F403


from enum import Enum

class TopicType(Enum):
    WORK = "work"
    DISCUSS = "discuss"
    WATCH = "watch"

WORKING_EVENT_TYPES = ['CreateEvent', 'PushEvent', 'PullRequestEvent']
DISCUSS_EVENT_TYPES = ['IssuesEvent', 'IssueCommentEvent', 'PullRequestReviewEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewThreadEvent']
WATCH_EVENT_TYPES = ['ForkEvent', 'WatchEvent']
EXPECETD_EVENT_TYPES = WORKING_EVENT_TYPES + DISCUSS_EVENT_TYPES + WATCH_EVENT_TYPES

UNKNOWN_SUMMARY = "Not enough information to summarize."
DEFAULT_TOPICS = {
    TopicType.WORK.value: UNKNOWN_SUMMARY,
    TopicType.DISCUSS.value: UNKNOWN_SUMMARY,
    TopicType.WATCH.value: UNKNOWN_SUMMARY,
}

def _zero_shot(prompt: str) -> str:
    """
    Core LLM call function to summarize repository topics using a zero-shot prompt.
    Returns a direct text summary.
    """
    try:
        client = openai.OpenAI(
            api_key=os.getenv("OPENAI_API_KEY"),
            base_url=os.getenv("OPENAI_BASE_URL"),
        )
        chat_completion = client.chat.completions.create(
            messages=[
                {
                    'role': 'user',
                    'content': prompt,
                }
            ],
            model=os.getenv("MODEL_NAME", "qwen-plus"),
        )
        content = chat_completion.choices[0].message.content
        return content.strip() if content else UNKNOWN_SUMMARY
    except Exception:
        return UNKNOWN_SUMMARY

def summarize_repos_for_working(repos: List[Dict[str, str]]) -> str:
    """
    Summarize topics for a list of repositories from a contributor's perspective.
    """
    repo_details = "\n".join([f"- {repo['name']}: {repo.get('description', 'No description')}" for repo in repos])
    prompt = f"""
    As a software development expert, analyze the following list of GitHub repositories from a contributor's perspective.
    Based on their names and descriptions, provide a brief and concise summary of the user's primary technical interests and contributions in plain text format, not markdown. Less than 60 words.
    Focus on the core domains and technologies.

    Repositories:
    {repo_details}
    """
    return _zero_shot(prompt)

def summarize_repos_for_discuss(repos: List[Dict[str, str]], repo_issue_titles: Dict[str, Set[str]]) -> str:
    """
    Summarize topics for a list of repositories from a community discussion perspective.
    """
    repo_details = "\n".join([f"- {repo['name']}: {repo.get('description', 'No description')}.\n\t- {'\n\t-'.join(repo_issue_titles.get(repo['name'], set()))}" for repo in repos])
    prompt = f"""
    As a software development expert, analyze the following list of GitHub repositories from a community discussion perspective.
    Based on their names and descriptions, write a brief and concise summary of the topics this user engages with in plain text format, not markdown. Less than 60 words. No comments and discussions is ok now.
    Mention the key problems and technologies involved.

    Repositories:
    - Repos: Description.
    \t- Title1
    \t- Title2

    {repo_details}
    """
    return _zero_shot(prompt)

def summarize_repos_for_watch(repos: List[Dict[str, str]]) -> str:
    """
    Summarize topics for a list of repositories from an observer's perspective.
    """
    repo_details = "\n".join([f"- {repo['name']}: {repo.get('description', 'No description')}" for repo in repos])
    prompt = f"""
    As a software development expert, analyze the following list of GitHub repositories from an observer's perspective.
    Based on their names and descriptions, briefly summarize the user's interests in technology trends and popular projects in plain text format, not markdown. Less than 60 words.

    Repositories:
    {repo_details}
    """
    return _zero_shot(prompt)

def summarize_topics(events: List[Event]) -> Dict[str, str]:
    """
    return topic -> summaries
    """
    if not events:
        return DEFAULT_TOPICS

    repos_by_topic: Dict[str, Dict[str, Dict[str, str]]] = {
        TopicType.WORK.value: {},
        TopicType.DISCUSS.value: {},
        TopicType.WATCH.value: {},
    }

    repo_info_cache: Dict[str, Dict[str, str]] = {} # to speed up getting repo_info
    discuss_repo2issue_titles: Dict[str, Set[str]] = defaultdict(set)
    for event in tqdm(events, leave=False, desc="collect event", position=1):
        if event.type not in EXPECETD_EVENT_TYPES:
            continue
        
        repo_name = event.repo.name
        if repo_name not in repo_info_cache:
            try:
                desc = event.repo.description
            except Exception:
                desc = ""
            repo_info = {'name': repo_name, 'description': desc}
            repo_info_cache[repo_name] = repo_info
            
        else:
            repo_info = repo_info_cache[repo_name]
        
        if event.type in WORKING_EVENT_TYPES:
            repos_by_topic[TopicType.WORK.value][repo_name] = repo_info
        if event.type in DISCUSS_EVENT_TYPES:
            title = ""
            if event.type in ['PullRequestReviewEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewThreadEvent']:
                pr = event.payload["pull_request"]
                if pr is None or "title" not in pr: # it seems that some PR does not have title
                    title = "unknown"
                else:
                    title = pr["title"]
            else:
                title = event.payload["issue"]["title"]
            discuss_repo2issue_titles[repo_name].add(title)
            repos_by_topic[TopicType.DISCUSS.value][repo_name] = repo_info
        if event.type in WATCH_EVENT_TYPES:
            repos_by_topic[TopicType.WATCH.value][repo_name] = repo_info

    topics = {}
    
    work_repos = list(repos_by_topic[TopicType.WORK.value].values())
    if work_repos:
        topics[TopicType.WORK.value] = summarize_repos_for_working(work_repos)
    else:
        topics[TopicType.WORK.value] = UNKNOWN_SUMMARY

    discuss_repos = list(repos_by_topic[TopicType.DISCUSS.value].values())
    if discuss_repos:
        topics[TopicType.DISCUSS.value] = summarize_repos_for_discuss(discuss_repos, discuss_repo2issue_titles)
    else:
        topics[TopicType.DISCUSS.value] = UNKNOWN_SUMMARY

    watch_repos = list(repos_by_topic[TopicType.WATCH.value].values())
    if watch_repos:
        topics[TopicType.WATCH.value] = summarize_repos_for_watch(watch_repos)
    else:
        topics[TopicType.WATCH.value] = UNKNOWN_SUMMARY
        
    return topics
