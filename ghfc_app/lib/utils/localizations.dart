import 'package:flutter/foundation.dart';

class AppLocalizations {
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'GitHub User Activity Tracking',
      'search_users': 'Filter Users',
      'event_type_filter': 'Event Type Filter',
      'select_all': 'Select All',
      'deselect_all': 'Deselect All',
      'close': 'Close',
      'view_docs': 'View Documentation',
      'work': 'Code & Commits',
      'discuss': 'Issues & PRs',
      'watch': 'Watch & Forks',
      'user_filter': 'User: ',
      'filter_users': 'Filter Users',
      'event_types': 'Event Types',
      // Event descriptions
      'WatchEvent_desc': 'Watch a repository',
      'PushEvent_desc': 'Pushed commits to a branch',
      'IssuesEvent_desc': 'Created, closed, or edited an Issue',
      'PullRequestEvent_desc': 'Opened, updated, or merged a Pull Request',
      'PullRequestReviewEvent_desc': 'Submitted or updated a PR review',
      'PullRequestReviewCommentEvent_desc': 'Added a comment in PR review',
      'PullRequestReviewThreadEvent_desc': 'Discussion thread in PR review',
      'DeleteEvent_desc': 'Deleted a branch or tag',
      'IssueCommentEvent_desc': 'Added a comment on an Issue',
      'CreateEvent_desc': 'Created a repo/branch/tag',
      'CommitCommentEvent_desc': 'Added a comment on a commit',
      'MemberEvent_desc': 'Added or removed a repository collaborator',
      'ForkEvent_desc': 'Forked a repository for modifications',
      'ReleaseEvent_desc': 'Released a software version',
      'GollumEvent_desc': 'Updated repository Wiki pages',
      'PublicEvent_desc': 'Made a repository public',
    },
    'zh': {
      'app_title': 'GitHub 用户活动追踪',
      'search_users': '筛选用户',
      'event_type_filter': '事件类型筛选',
      'select_all': '全选',
      'deselect_all': '全不选',
      'close': '关闭',
      'view_docs': '查看文档',
      'work': '代码提交',
      'discuss': '讨论协作',
      'watch': '观察分叉',
      'user_filter': '用户: ',
      'filter_users': '筛选用户',
      'event_types': '事件类型',
      // Event descriptions
      'WatchEvent_desc': '关注特定仓库',
      'PushEvent_desc': '向分支推送提交',
      'IssuesEvent_desc': '创建、关闭或编辑 Issue',
      'PullRequestEvent_desc': '打开、更新或合并 Pull Request',
      'PullRequestReviewEvent_desc': '提交或更新 PR 评审',
      'PullRequestReviewCommentEvent_desc': '在 PR 评审中添加评论',
      'PullRequestReviewThreadEvent_desc': 'PR 评审会话的讨论线程',
      'DeleteEvent_desc': '删除分支或标签',
      'IssueCommentEvent_desc': '在 Issue 下添加评论',
      'CreateEvent_desc': '创建仓库、分支或标签',
      'CommitCommentEvent_desc': '对提交添加评论',
      'MemberEvent_desc': '添加或移除仓库协作者',
      'ForkEvent_desc': '派生仓库以进行修改',
      'ReleaseEvent_desc': '发布软件版本',
      'GollumEvent_desc': '更新仓库 Wiki 页面',
      'PublicEvent_desc': '将仓库设置为公开',
    },
  };

  static String _currentLanguage = 'zh'; // Default to Chinese
  static final ValueNotifier<String> _languageNotifier = ValueNotifier<String>(_currentLanguage);

  static void setLanguage(String language) {
    _currentLanguage = language;
    _languageNotifier.value = language;
  }

  static String translate(String key) {
    return _localizedValues[_currentLanguage]?[key] ?? _localizedValues['en']?[key] ?? key;
  }

  static ValueNotifier<String> get languageNotifier => _languageNotifier;

  // Convenience getters for common strings
  static String get appTitle => translate('app_title');
  static String get searchUsers => translate('search_users');
  static String get eventTypeFilter => translate('event_type_filter');
  static String get selectAll => translate('select_all');
  static String get deselectAll => translate('deselect_all');
  static String get close => translate('close');
  static String get viewDocs => translate('view_docs');
  static String get work => translate('work');
  static String get discuss => translate('discuss');
  static String get watch => translate('watch');
  static String get userFilter => translate('user_filter');
  static String get filterUsers => translate('filter_users');
  static String get eventTypes => translate('event_types');
  
  // Event description getters
  static String get watchEventDesc => translate('WatchEvent_desc');
  static String get pushEventDesc => translate('PushEvent_desc');
  static String get issuesEventDesc => translate('IssuesEvent_desc');
  static String get pullRequestEventDesc => translate('PullRequestEvent_desc');
  static String get pullRequestReviewEventDesc => translate('PullRequestReviewEvent_desc');
  static String get pullRequestReviewCommentEventDesc => translate('PullRequestReviewCommentEvent_desc');
  static String get pullRequestReviewThreadEventDesc => translate('PullRequestReviewThreadEvent_desc');
  static String get deleteEventDesc => translate('DeleteEvent_desc');
  static String get issueCommentEventDesc => translate('IssueCommentEvent_desc');
  static String get createEventDesc => translate('CreateEvent_desc');
  static String get commitCommentEventDesc => translate('CommitCommentEvent_desc');
  static String get memberEventDesc => translate('MemberEvent_desc');
  static String get forkEventDesc => translate('ForkEvent_desc');
  static String get releaseEventDesc => translate('ReleaseEvent_desc');
  static String get gollumEventDesc => translate('GollumEvent_desc');
  static String get publicEventDesc => translate('PublicEvent_desc');
}