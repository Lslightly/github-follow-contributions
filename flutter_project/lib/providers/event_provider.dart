import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import '../models/event_data.dart';

class EventProvider with ChangeNotifier {
  List<EventData> _users = [];
  List<String> _eventTypes = [];
  List<String> _selectedEventTypes = [];
  
  final Map<String, List<String>> topicCategories = {
    'work': ['CreateEvent', 'PushEvent', 'PullRequestEvent'],
    'discuss': ['IssuesEvent', 'IssueCommentEvent', 'PullRequestReviewEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewThreadEvent'],
    'watch': ['ForkEvent', 'WatchEvent'],
  };

  final Map<String, Map<String, String>> enumEventTypeStyles = {
    'WatchEvent': {'backgroundColor': '#e3fcec', 'color': '#026034'},
    'PushEvent': {'backgroundColor': '#ddf4ff', 'color': '#0550ae'},
    'IssuesEvent': {'backgroundColor': '#f1f8ff', 'color': '#0366d6'},
    'PullRequestEvent': {'backgroundColor': '#f0f8ff', 'color': '#0366d6'},
    'PullRequestReviewEvent': {'backgroundColor': '#f0f8ff', 'color': '#0366d6'},
    'PullRequestReviewCommentEvent': {'backgroundColor': '#f0f8ff', 'color': '#0366d6'},
    'DeleteEvent': {'backgroundColor': '#f1f8ff', 'color': '#0366d6'},
    'IssueCommentEvent': {'backgroundColor': '#f1f8ff', 'color': '#0366d6'},
    'CreateEvent': {'backgroundColor': '#f0f8ff', 'color': '#0366d6'},
    'CommitCommentEvent': {'backgroundColor': '#f1f8ff', 'color': '#0366d6'},
    'MemberEvent': {'backgroundColor': '#f0f8ff', 'color': '#0366d6'},
    'ForkEvent': {'backgroundColor': '#f0f8ff', 'color': '#0366d6'},
    'ReleaseEvent': {'backgroundColor': '#f0f8ff', 'color': '#0366d6'},
    'GollumEvent': {'backgroundColor': '#f0f8ff', 'color': '#0366d6'},
    'PublicEvent': {'backgroundColor': '#f1f8ff', 'color': '#0366d6'},
  };

  final Map<String, String> enumEventShortNames = {
    'WatchEvent': 'Watch',
    'PushEvent': 'Push',
    'IssuesEvent': 'Issue',
    'PullRequestEvent': 'PR',
    'PullRequestReviewEvent': 'Review',
    'PullRequestReviewCommentEvent': 'PRComment',
    'DeleteEvent': 'Delete',
    'IssueCommentEvent': 'IssueComment',
    'CreateEvent': 'Create',
    'CommitCommentEvent': 'CommitComment',
    'MemberEvent': 'Member',
    'ForkEvent': 'Fork',
    'ReleaseEvent': 'Release',
    'GollumEvent': 'Gollum',
    'PublicEvent': 'Public',
  };

  List<EventData> get users => _users;
  List<String> get eventTypes => _eventTypes;
  List<String> get selectedEventTypes => _selectedEventTypes;
  
  bool get allEventsSelected => 
    _eventTypes.isNotEmpty && _selectedEventTypes.length == _eventTypes.length;

  Future<void> loadEvents() async {
    try {
      final String response = await rootBundle.loadString('assets/events.json');
      final data = jsonDecode(response);
      
      _users = (data as List).map((user) => EventData.fromJson(user)).toList();
      _eventTypes = enumEventTypeStyles.keys.toList();
      _selectedEventTypes = [..._eventTypes];
      
      notifyListeners();
    } catch (e) {
      print('Error loading events: $e');
    }
  }

  void setAllEventsSelected(bool value) {
    if (value) {
      _selectedEventTypes = [..._eventTypes];
    } else {
      _selectedEventTypes = [];
    }
    notifyListeners();
  }

  void toggleEventType(String eventType) {
    if (_selectedEventTypes.contains(eventType)) {
      _selectedEventTypes.remove(eventType);
    } else {
      _selectedEventTypes.add(eventType);
    }
    notifyListeners();
  }

  List<EventData> get filteredUsers {
    return _users.map((user) {
      final filteredEvents = user.events.where((event) => 
        _selectedEventTypes.contains(event[1])).toList();
      return EventData(
        username: user.username,
        events: filteredEvents,
        summaryTopics: user.summaryTopics,
      );
    }).where((user) => user.events.isNotEmpty).toList();
  }
}