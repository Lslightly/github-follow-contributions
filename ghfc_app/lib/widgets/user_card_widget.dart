import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/event_data.dart';
import '../providers/event_provider.dart';
import 'package:provider/provider.dart';

class UserCardWidget extends StatelessWidget {
  final EventData user;
  
  const UserCardWidget({
    super.key,
    required this.user,
  });

  Map<String, Map<String, List<dynamic>>> getGroupedEvents() {
    final eventMap = <String, Map<String, List<dynamic>>>{};
    for (final event in user.events) {
      final repoName = event[0] as String;
      final eventType = event[1] as String;
      final eventPayload = event[2];
      
      if (!eventMap.containsKey(repoName)) {
        eventMap[repoName] = {};
      }
      if (!eventMap[repoName]!.containsKey(eventType)) {
        eventMap[repoName]![eventType] = [];
      }
      eventMap[repoName]![eventType]!.add(eventPayload);
    }
    return eventMap;
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final groupedEvents = getGroupedEvents();
    final eventEntries = groupedEvents.entries.toList();
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE1E4E8)),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _Avatar(username: user.username),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () => _launchUrl('https://github.com/${user.username}'),
                    child: Text(
                      user.username,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF24292E),
                      ),
                    ),
                  ),
                ],
              ),
              // Summary tags
              Row(
                children: [
                  _buildSummaryTag(
                    context,
                    'work',
                    user.summaryTopics['work'] ?? '',
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  _buildSummaryTag(
                    context,
                    'discuss',
                    user.summaryTopics['discuss'] ?? '',
                    Theme.of(context).colorScheme.secondaryContainer,
                    Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 8),
                  _buildSummaryTag(
                    context,
                    'watch',
                    user.summaryTopics['watch'] ?? '',
                    Theme.of(context).colorScheme.tertiaryContainer,
                    Theme.of(context).colorScheme.onTertiaryContainer,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          
          if (eventEntries.length <= 6)
            ...eventEntries.map((entry) => _buildEventRow(context, entry, eventProvider))
          else
            SizedBox(
              height: 240,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                physics: const ClampingScrollPhysics(),
                itemCount: eventEntries.length,
                itemBuilder: (context, index) {
                  final entry = eventEntries[index];
                  return _buildEventRow(context, entry, eventProvider);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEventRow(BuildContext context, MapEntry<String, Map<String, List<dynamic>>> entry, EventProvider eventProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEAECEF))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _launchUrl('https://github.com/${entry.key}'),
              child: Text(
                entry.key,
                style: const TextStyle(
                  color: Color(0xFF0366D6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 4,
              runSpacing: 4,
              children: [
                ...entry.value.entries.map((eventEntry) => 
                  _buildEventTag(context, eventEntry.key, eventEntry.value, entry.key, eventProvider),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTag(BuildContext context, String title, String tooltip, Color backgroundColor, Color textColor) {
    return Tooltip(
      message: tooltip,
      preferBelow: false,
      verticalOffset: 14,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEventTag(BuildContext context, String eventType, List<dynamic> payloads, String repoName, EventProvider eventProvider) {
    Color backgroundColor;
    Color textColor;
    if ((eventProvider.topicCategories['work'] ?? const []).contains(eventType)) {
      backgroundColor = Theme.of(context).colorScheme.primaryContainer;
      textColor = Theme.of(context).colorScheme.onPrimaryContainer;
    } else if ((eventProvider.topicCategories['discuss'] ?? const []).contains(eventType)) {
      backgroundColor = Theme.of(context).colorScheme.secondaryContainer;
      textColor = Theme.of(context).colorScheme.onSecondaryContainer;
    } else if ((eventProvider.topicCategories['watch'] ?? const []).contains(eventType)) {
      backgroundColor = Theme.of(context).colorScheme.tertiaryContainer;
      textColor = Theme.of(context).colorScheme.onTertiaryContainer;
    } else {
      final style = eventProvider.enumEventTypeStyles[eventType] ?? {};
      backgroundColor = Color(int.parse(style['backgroundColor']?.substring(1) ?? 'f3f4f6', radix: 16) + 0xFF000000);
      textColor = Color(int.parse(style['color']?.substring(1) ?? '586069', radix: 16) + 0xFF000000);
    }

    final link = LayerLink();

    return CompositedTransformTarget(
      link: link,
      child: InkWell(
        onTap: () => _showEventPopover(context, link, eventType, payloads, repoName),
        onLongPress: () => _showEventPopover(context, link, eventType, payloads, repoName),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: textColor.withValues(alpha: 0.25)),
          ),
          child: Text(
            eventProvider.enumEventShortNames[eventType] ?? eventType,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  void _showEventPopover(BuildContext context, LayerLink link, String eventType, List<dynamic> payloads, String repoName) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        final items = _buildEventLinks(eventType, payloads, repoName);
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(onTap: () => entry.remove()),
            ),
            CompositedTransformFollower(
              link: link,
              offset: const Offset(0, -8),
              showWhenUnlinked: false,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 260),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...items.map((it) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: InkWell(
                              onTap: () {
                                _launchUrl(it['url']!);
                                entry.remove();
                              },
                              child: Text(
                                it['label']!,
                                style: TextStyle(
                                  color: scheme.primary,
                                  decoration: TextDecoration.underline,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    overlay.insert(entry);
  }

  List<Map<String, String>> _buildEventLinks(String eventType, List<dynamic> payloads, String repoName) {
    final limited = payloads.take(5).toList();
    final List<Map<String, String>> out = [];
    switch (eventType) {
      case 'WatchEvent':
        out.add({'label': 'Watch $repoName', 'url': 'https://github.com/$repoName'});
        break;
      case 'PushEvent':
        for (final p in limited) {
          final head = (p['head'] ?? '').toString();
          if (head.isNotEmpty) {
            out.add({'label': 'commit ${head.substring(0, head.length.clamp(0, 7))}', 'url': 'https://github.com/$repoName/commit/$head'});
          }
        }
        break;
      case 'IssuesEvent':
        for (final p in limited) {
          final num = p['issue']?['number']?.toString() ?? '';
          if (num.isNotEmpty) {
            out.add({'label': 'issue #$num', 'url': 'https://github.com/$repoName/issues/$num'});
          }
        }
        break;
      case 'PullRequestEvent':
      case 'PullRequestReviewEvent':
      case 'PullRequestReviewCommentEvent':
      case 'PullRequestReviewThreadEvent':
        for (final p in limited) {
          final num = p['pull_request']?['number']?.toString() ?? '';
          if (num.isNotEmpty) {
            out.add({'label': 'PR #$num', 'url': 'https://github.com/$repoName/pull/$num'});
          }
        }
        break;
      case 'DeleteEvent':
        for (final p in limited) {
          final ref = (p['ref'] ?? '').toString();
          if (ref.isNotEmpty) {
            out.add({'label': 'deleted $ref', 'url': 'https://github.com/$repoName'});
          }
        }
        break;
      case 'IssueCommentEvent':
        for (final p in limited) {
          final num = p['issue']?['number']?.toString() ?? '';
          if (num.isNotEmpty) {
            out.add({'label': 'comment on #$num', 'url': 'https://github.com/$repoName/issues/$num'});
          }
        }
        break;
      case 'CreateEvent':
        for (final p in limited) {
          final refType = (p['ref_type'] ?? '').toString();
          final ref = (p['ref'] ?? '').toString();
          if (refType == 'branch' && ref.isNotEmpty) {
            out.add({'label': 'branch $ref', 'url': 'https://github.com/$repoName/tree/$ref'});
          } else if (refType == 'tag' && ref.isNotEmpty) {
            out.add({'label': 'tag $ref', 'url': 'https://github.com/$repoName/releases/tag/$ref'});
          } else {
            out.add({'label': repoName, 'url': 'https://github.com/$repoName'});
          }
        }
        break;
      case 'ForkEvent':
        for (final p in limited) {
          final fullName = p['forkee']?['full_name']?.toString() ?? '';
          if (fullName.isNotEmpty) {
            out.add({'label': 'fork $fullName', 'url': 'https://github.com/$fullName'});
          }
        }
        break;
      case 'ReleaseEvent':
        for (final p in limited) {
          final tag = p['release']?['tag_name']?.toString() ?? '';
          final html = p['release']?['html_url']?.toString() ?? '';
          final url = html.isNotEmpty ? html : 'https://github.com/$repoName/releases';
          final label = tag.isNotEmpty ? 'release $tag' : 'release';
          out.add({'label': label, 'url': url});
        }
        break;
      default:
        out.add({'label': eventType, 'url': 'https://github.com/$repoName'});
        break;
    }
    if (out.isEmpty) {
      out.add({'label': repoName, 'url': 'https://github.com/$repoName'});
    }
    return out;
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _Avatar extends StatefulWidget {
  final String username;
  const _Avatar({required this.username});

  @override
  State<_Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<_Avatar> {
  bool _failed = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);
  
  @override
  void initState() {
    super.initState();
    _startRetryTimer();
  }
  
  void _startRetryTimer() {
    // 如果头像加载失败，启动重试定时器
    if (_failed && _retryCount < _maxRetries) {
      Future.delayed(_retryDelay * (_retryCount + 1), () {
        if (mounted && _failed) {
          setState(() {
            _failed = false; // 重置失败状态，重新尝试加载
          });
        }
      });
    }
  }
  
  void _onImageError(Object error, StackTrace? stackTrace) {
    if (mounted) {
      setState(() {
        _failed = true;
        _retryCount++;
      });
      _startRetryTimer(); // 启动下一次重试
    }
  }
  
  void _manualRetry() {
    if (mounted) {
      setState(() {
        _failed = false;
        _retryCount = 0; // 重置重试计数
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        children: [
          // 头像主体
          Positioned.fill(
            child: _failed
                ? CircleAvatar(
                    child: Text(
                      widget.username.substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  )
                : CircleAvatar(
                    backgroundImage: NetworkImage(
                        'https://avatars.githubusercontent.com/${widget.username}?v=4&s=80'),
                    onBackgroundImageError: _onImageError,
                  ),
          ),
          // 刷新按钮（仅在失败时显示）
          if (_failed)
            Positioned(
              right: -4,
              top: -4,
              child: GestureDetector(
                onTap: _manualRetry,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.refresh,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}