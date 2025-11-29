import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../models/event_data.dart';
import '../utils/localizations.dart';

class EventProvider extends ChangeNotifier {
  List<EventData> _users = [];
  List<String> _eventTypes = [];
  List<String> _selectedEventTypes = [];
  String _userQuery = '';
  String? _errorMessage;
  
  // Pagination and lazy loading
  int _currentPage = 0;
  static const int _pageSize = 10;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  List<EventData> _displayedUsers = [];
  
  EventProvider() {
    // 监听语言变化，及时更新事件描述
    AppLocalizations.languageNotifier.addListener(_onLanguageChanged);
  }
  
  @override
  void dispose() {
    AppLocalizations.languageNotifier.removeListener(_onLanguageChanged);
    super.dispose();
  }
  
  void _onLanguageChanged() {
    // 语言切换时通知所有监听者重新构建
    notifyListeners();
  }
  
  final Map<String, List<String>> topicCategories = {
    'work': ['CreateEvent', 'PushEvent', 'PullRequestEvent'],
    'discuss': ['IssuesEvent', 'IssueCommentEvent', 'PullRequestReviewEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewThreadEvent'],
    'watch': ['ForkEvent', 'WatchEvent'],
  };

  final Map<String, Map<String, String>> enumEventTypeStyles = {
    'WatchEvent': {'backgroundColor': '#dafbe1', 'color': '#026034'},
    'PushEvent': {'backgroundColor': '#ffebe9', 'color': '#cf222e'},
    'IssuesEvent': {'backgroundColor': '#ddf4ff', 'color': '#0550ae'},
    'PullRequestEvent': {'backgroundColor': '#ffebe9', 'color': '#cf222e'},
    'PullRequestReviewEvent': {'backgroundColor': '#ddf4ff', 'color': '#0550ae'},
    'PullRequestReviewCommentEvent': {'backgroundColor': '#ddf4ff', 'color': '#0550ae'},
    'PullRequestReviewThreadEvent': {'backgroundColor': '#ddf4ff', 'color': '#0550ae'},
    'DeleteEvent': {'backgroundColor': '#f1f8ff', 'color': '#0366d6'},
    'IssueCommentEvent': {'backgroundColor': '#ddf4ff', 'color': '#0550ae'},
    'CreateEvent': {'backgroundColor': '#ffebe9', 'color': '#cf222e'},
    'CommitCommentEvent': {'backgroundColor': '#f1f8ff', 'color': '#0366d6'},
    'MemberEvent': {'backgroundColor': '#f0f8ff', 'color': '#0366d6'},
    'ForkEvent': {'backgroundColor': '#dafbe1', 'color': '#026034'},
    'ReleaseEvent': {'backgroundColor': '#f0f8ff', 'color': '#0366d6'},
    'GollumEvent': {'backgroundColor': '#f0f8ff', 'color': '#0366d6'},
    'PublicEvent': {'backgroundColor': '#f1f8ff', 'color': '#0366d6'},
  };

  final Map<String, String> eventDocLinks = {
    'WatchEvent': 'https://docs.github.com/en/webhooks/webhook-events-and-payloads#watch',
    'PushEvent': 'https://docs.github.com/en/webhooks/webhook-events-and-payloads#push',
    'IssuesEvent': 'https://docs.github.com/en/webhooks/webhook-events-and-payloads#issues',
    'PullRequestEvent': 'https://docs.github.com/en/webhooks/webhook-events-and-payloads#pull_request',
    'PullRequestReviewEvent': 'https://docs.github.com/en/webhooks/webhook-events-and-payloads#pull_request_review',
    'PullRequestReviewCommentEvent': 'https://docs.github.com/en/webhooks/webhook-events-and-payloads#pull_request_review_comment',
    'PullRequestReviewThreadEvent': 'https://docs.github.com/en/webhooks/webhook-events-and-payloads#pull_request_review_thread',
    'DeleteEvent': 'https://docs.github.com/en/webhooks/webhook-events-and-payloads#delete',
    'IssueCommentEvent': 'https://docs.github.com/en/webhooks/webhook-events-and-payloads#issue_comment',
    'CreateEvent': 'https://docs.github.com/en/webhooks/webhook-events-and-payloads#create',
    'CommitCommentEvent': 'https://docs.github.com/en/webhooks/webhook-events-and-payloads#commit_comment',
    'MemberEvent': 'https://docs.github.com/en/webhooks/webhook-events-and-payloads#member',
    'ForkEvent': 'https://docs.github.com/en/webhooks/webhook-events-and-payloads#fork',
    'ReleaseEvent': 'https://docs.github.com/en/webhooks/webhook-events-and-payloads#release',
    'GollumEvent': 'https://docs.github.com/en/webhooks/webhook-events-and-payloads#gollum',
    'PublicEvent': 'https://docs.github.com/en/webhooks/webhook-events-and-payloads#public',
  };

  // 动态获取事件描述，支持语言切换
  String getEventDescription(String eventType) {
    switch (eventType) {
      case 'WatchEvent':
        return AppLocalizations.watchEventDesc;
      case 'PushEvent':
        return AppLocalizations.pushEventDesc;
      case 'IssuesEvent':
        return AppLocalizations.issuesEventDesc;
      case 'PullRequestEvent':
        return AppLocalizations.pullRequestEventDesc;
      case 'PullRequestReviewEvent':
        return AppLocalizations.pullRequestReviewEventDesc;
      case 'PullRequestReviewCommentEvent':
        return AppLocalizations.pullRequestReviewCommentEventDesc;
      case 'PullRequestReviewThreadEvent':
        return AppLocalizations.pullRequestReviewThreadEventDesc;
      case 'DeleteEvent':
        return AppLocalizations.deleteEventDesc;
      case 'IssueCommentEvent':
        return AppLocalizations.issueCommentEventDesc;
      case 'CreateEvent':
        return AppLocalizations.createEventDesc;
      case 'CommitCommentEvent':
        return AppLocalizations.commitCommentEventDesc;
      case 'MemberEvent':
        return AppLocalizations.memberEventDesc;
      case 'ForkEvent':
        return AppLocalizations.forkEventDesc;
      case 'ReleaseEvent':
        return AppLocalizations.releaseEventDesc;
      case 'GollumEvent':
        return AppLocalizations.gollumEventDesc;
      case 'PublicEvent':
        return AppLocalizations.publicEventDesc;
      default:
        return eventType;
    }
  }

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
  String get userQuery => _userQuery;
  String? get errorMessage => _errorMessage;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMoreData;
  List<EventData> get displayedUsers => _displayedUsers;
  
  bool get allEventsSelected => 
    _eventTypes.isNotEmpty && _selectedEventTypes.length == _eventTypes.length;

  Future<void> loadEvents() async {
    _errorMessage = null;
    _currentPage = 0;
    _hasMoreData = true;
    _displayedUsers = [];
    
    try {
      String response = await rootBundle.loadString('assets/events.json');
      final data = jsonDecode(response);
      _users = (data as List).map((user) => EventData.fromJson(user)).toList();
      _eventTypes = enumEventTypeStyles.keys.toList();
      _selectedEventTypes = [..._eventTypes];
      
      // Load first page
      await _loadMoreUsers();
      
      notifyListeners();
    } catch (e) {
      try {
        String response = await rootBundle.loadString('assets/assets/events.json');
        final data = jsonDecode(response);
        _users = (data as List).map((user) => EventData.fromJson(user)).toList();
        _eventTypes = enumEventTypeStyles.keys.toList();
        _selectedEventTypes = [..._eventTypes];
        
        // Load first page
        await _loadMoreUsers();
        
        notifyListeners();
      } catch (e2) {
        _errorMessage = '加载事件数据失败';
        notifyListeners();
      }
    }
  }
  
  Future<void> _loadMoreUsers() async {
    if (_isLoadingMore || !_hasMoreData) return;
    _isLoadingMore = true;
    
    // Simulate network delay for better UX
    await Future.delayed(const Duration(milliseconds: 300));
    
    final filteredUsers = this.filteredUsers;
    final startIndex = _currentPage * _pageSize;
    final endIndex = startIndex + _pageSize;
    
    if (startIndex >= filteredUsers.length) {
      _hasMoreData = false;
      _isLoadingMore = false;
      notifyListeners();
      return;
    }
    
    final newUsers = filteredUsers.sublist(
      startIndex,
      endIndex.clamp(0, filteredUsers.length),
    );
    
    _displayedUsers.addAll(newUsers);
    _currentPage++;
    _hasMoreData = endIndex < filteredUsers.length;
    _isLoadingMore = false;
    notifyListeners();
  }
  
  Future<void> loadMoreUsers() async {
    await _loadMoreUsers();
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
    _resetPaginationAndReload();
  }

  void setUserQuery(String query) {
    _userQuery = query.trim();
    _resetPaginationAndReload();
  }

  List<EventData> get filteredUsers {
    final filtered = _users.map((user) {
      final filteredEvents = user.events.where((event) => 
        _selectedEventTypes.contains(event[1])).toList();
      return EventData(
        username: user.username,
        events: filteredEvents,
        summaryTopics: user.summaryTopics,
      );
    }).where((user) {
      if (user.events.isNotEmpty == false) return false;
      if (_userQuery.isEmpty) return true;
      return user.username.toLowerCase().contains(_userQuery.toLowerCase());
    }).toList();
    return filtered;
  }

  Future<void> reloadEvents() async {
    await loadEvents();
  }

  void _resetPaginationAndReload() {
    _currentPage = 0;
    _hasMoreData = true;
    _displayedUsers = [];
    notifyListeners();
    _loadMoreUsers();
  }
}