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
                  CircleAvatar(
                    backgroundImage: NetworkImage('https://github.com/${user.username}.png'),
                    radius: 20,
                  ),
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
                  _buildSummaryTag('work', user.summaryTopics['work'] ?? '', 
                    const Color(0xFFDDf4FF), const Color(0xFF0550AE)),
                  const SizedBox(width: 8),
                  _buildSummaryTag('discuss', user.summaryTopics['discuss'] ?? '', 
                    const Color(0xFFF1F8FF), const Color(0xFF0366D6)),
                  const SizedBox(width: 8),
                  _buildSummaryTag('watch', user.summaryTopics['watch'] ?? '', 
                    const Color(0xFFE3FCEC), const Color(0xFF026034)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          
          // Events
          ...groupedEvents.entries.map((entry) => 
            Container(
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
                      children: entry.value.entries.map((eventEntry) => 
                        _buildEventTag(eventEntry.key, eventEntry.value, entry.key, eventProvider),
                      ).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ).toList(),
        ],
      ),
    );
  }

  Widget _buildSummaryTag(String title, String tooltip, Color backgroundColor, Color textColor) {
    return Tooltip(
      message: tooltip,
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

  Widget _buildEventTag(String eventType, List<dynamic> payloads, String repoName, EventProvider eventProvider) {
    final style = eventProvider.enumEventTypeStyles[eventType] ?? {};
    final backgroundColor = Color(int.parse(style['backgroundColor']?.substring(1) ?? 'f3f4f6', radix: 16) + 0xFF000000);
    final textColor = Color(int.parse(style['color']?.substring(1) ?? '586069', radix: 16) + 0xFF000000);
    
    return Tooltip(
      message: _generateTooltipContent(eventType, payloads, repoName),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          eventProvider.enumEventShortNames[eventType] ?? eventType,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  String _generateTooltipContent(String eventType, List<dynamic> payloads, String repoName) {
    final limitedPayloads = payloads.take(5).toList();
    
    switch (eventType) {
      case 'WatchEvent':
        return 'Watch';
      case 'PushEvent':
        return limitedPayloads.map((p) {
          final head = p['head'] ?? '';
          return head.toString().substring(0, head.toString().length.clamp(0, 6));
        }).join(', ');
      case 'IssuesEvent':
        return limitedPayloads.map((p) => '#${p['issue']['number']}').join(', ');
      case 'PullRequestEvent':
      case 'PullRequestReviewEvent':
        return limitedPayloads.map((p) => '#${p['pull_request']['number']}').join(', ');
      case 'PullRequestReviewCommentEvent':
        return limitedPayloads.map((p) => '#${p['pull_request']['number']}').join(', ');
      case 'DeleteEvent':
        return limitedPayloads.map((p) => p['ref'] ?? '').join(', ');
      case 'IssueCommentEvent':
        return limitedPayloads.map((p) => '#${p['issue']['number']}').join(', ');
      case 'CreateEvent':
        return limitedPayloads.map((p) {
          if (p['ref_type'] != 'repository') {
            return p['ref'] ?? '';
          }
          return repoName;
        }).join(', ');
      case 'ForkEvent':
        return payloads.map((p) => p['forkee']['full_name'] ?? '').join(', ');
      case 'ReleaseEvent':
        return payloads.map((p) => p['release']['name'] ?? '').join(', ');
      default:
        return eventType;
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}