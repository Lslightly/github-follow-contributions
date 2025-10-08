import pytest
from unittest.mock import MagicMock
from github.Event import Event

# Assume event_analysis.py is in the same directory or accessible via PYTHONPATH
from event_analysis import (
    summarize_topics,
    TopicType,
    DEFAULT_TOPICS,
    UNKNOWN_SUMMARY
)

@pytest.fixture
def mock_events():
    """Fixture to create mock event objects for testing."""
    # Mock Repo objects
    mock_repo1 = MagicMock()
    mock_repo1.name = "user/repo1"
    mock_repo1.description = "Description for repo1"

    mock_repo2 = MagicMock()
    mock_repo2.name = "user/repo2"
    mock_repo2.description = "Description for repo2"

    # Mock Event objects
    event1 = MagicMock(spec=Event)
    event1.type = "PushEvent"  # WORKING
    event1.repo = mock_repo1

    event2 = MagicMock(spec=Event)
    event2.type = "IssuesEvent"  # DISCUSS
    event2.repo = mock_repo1

    event3 = MagicMock(spec=Event)
    event3.type = "WatchEvent"  # WATCH
    event3.repo = mock_repo2
    
    event4 = MagicMock(spec=Event)
    event4.type = "PushEvent" # WORKING in repo2
    event4.repo = mock_repo2

    event5 = MagicMock(spec=Event)
    event5.type = "UnrelatedEvent"
    event5.repo = mock_repo1
    
    event6 = MagicMock(spec=Event)
    event6.type = "CreateEvent" # WORKING
    event6.repo = mock_repo1

    return [event1, event2, event3, event4, event5, event6]

def test_summarize_topics_returns_string_summary(mocker, mock_events):
    """
    Tests the refactored core logic of summarize_topics, ensuring it returns
    a dictionary of string summaries.
    """
    # Mock the new batch summarization functions to return string summaries
    mock_work = mocker.patch('event_analysis.summarize_repos_for_working', return_value='Summary of work.')
    mock_discuss = mocker.patch('event_analysis.summarize_repos_for_discuss', return_value='Summary of discussions.')
    mock_watch = mocker.patch('event_analysis.summarize_repos_for_watch', return_value='Summary of watched repos.')

    result = summarize_topics(mock_events)

    # Assert that batch summarization functions were called once per topic type
    mock_work.assert_called_once()
    mock_discuss.assert_called_once()
    mock_watch.assert_called_once()

    # Assert the final aggregated topics are correct
    expected_topics = {
        TopicType.WORK.value: 'Summary of work.',
        TopicType.DISCUSS.value: 'Summary of discussions.',
        TopicType.WATCH.value: 'Summary of watched repos.'
    }
    assert result == expected_topics

def test_empty_events_list():
    """Tests that summarize_topics returns default topics for an empty event list."""
    assert summarize_topics([]) == DEFAULT_TOPICS

def test_no_relevant_events():
    """
    Tests that summarize_topics returns default topics when events have no relevant types.
    """
    mock_repo = MagicMock()
    mock_repo.name = "user/repo"
    mock_repo.description = "A repo"
    
    irrelevant_event = MagicMock(spec=Event)
    irrelevant_event.type = "UnrelatedEvent"
    irrelevant_event.repo = mock_repo
    
    assert summarize_topics([irrelevant_event]) == DEFAULT_TOPICS

def test_summarize_topics_with_no_repos_for_a_category(mocker):
    """
    Tests that if a topic category has no associated repos, it defaults to UNKNOWN_SUMMARY.
    """
    mock_repo = MagicMock()
    mock_repo.name = "user/repo1"
    mock_repo.description = "Description for repo1"
    
    work_event = MagicMock(spec=Event)
    work_event.type = "PushEvent"
    work_event.repo = mock_repo

    mocker.patch('event_analysis.summarize_repos_for_working', return_value='Summary of work.')
    mocker.patch('event_analysis.summarize_repos_for_discuss')
    mocker.patch('event_analysis.summarize_repos_for_watch')

    result = summarize_topics([work_event])

    expected_topics = {
        TopicType.WORK.value: 'Summary of work.',
        TopicType.DISCUSS.value: UNKNOWN_SUMMARY,
        TopicType.WATCH.value: UNKNOWN_SUMMARY
    }
    assert result == expected_topics