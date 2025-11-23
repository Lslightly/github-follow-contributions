import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class LegendWidget extends StatefulWidget {
  const LegendWidget({super.key});

  @override
  State<LegendWidget> createState() => _LegendWidgetState();
}

class _LegendWidgetState extends State<LegendWidget> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    
    return Column(
      children: [
        _buildHeader(eventProvider),
        if (_expanded) _buildExpandedContent(eventProvider),
      ],
    );
  }

  Color _getCategoryColor(BuildContext context, String category) {
    switch (category) {
      case 'work':
        return Theme.of(context).colorScheme.primaryContainer;
      case 'discuss':
        return Theme.of(context).colorScheme.secondaryContainer;
      case 'watch':
        return Theme.of(context).colorScheme.tertiaryContainer;
      default:
        return Colors.grey;
    }
  }

  Widget _buildHeader(EventProvider eventProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE1E4E8)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '事件类型说明',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Row(
            children: [
              // Filter controls
              if (_expanded) ...[
                TextButton(
                  onPressed: () => eventProvider.setAllEventsSelected(true),
                  child: const Text('全选', style: TextStyle(fontSize: 12)),
                ),
                TextButton(
                  onPressed: () => eventProvider.setAllEventsSelected(false),
                  child: const Text('全不选', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),
              ],
              // Collapse button
              IconButton(
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more, size: 20),
                onPressed: () => setState(() => _expanded = !_expanded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(EventProvider eventProvider) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE1E4E8)),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...eventProvider.topicCategories.entries.map((entry) => _buildCategoryItem(entry, eventProvider)),
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              '将鼠标悬浮在tag上以获得总结，长按查询文档。',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Color(0xFF586069),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(MapEntry<String, List<String>> entry, EventProvider eventProvider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: _getCategoryColor(context, entry.key),
            ),
            child: Text(
              entry.key,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            '→',
            style: TextStyle(
              color: Color(0xFF586069),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: entry.value.map<Widget>((event) => _buildEventCheckbox(event, eventProvider)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCheckbox(String event, EventProvider eventProvider) {
    final isSelected = eventProvider.selectedEventTypes.contains(event);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onLongPress: () => _showEventDocumentation(event, eventProvider),
          child: Tooltip(
            message: eventProvider.eventDescriptions[event] ?? event,
            preferBelow: false,
            verticalOffset: 10,
            waitDuration: const Duration(milliseconds: 250),
            showDuration: const Duration(seconds: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: (_) => eventProvider.toggleEventType(event),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                Text(
                  eventProvider.enumEventShortNames[event] ?? event,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showEventDocumentation(String event, EventProvider eventProvider) {
    final link = eventProvider.eventDocLinks[event] ?? 'https://docs.github.com/en/webhooks/webhook-events-and-payloads';
    final desc = eventProvider.eventDescriptions[event] ?? event;
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eventProvider.enumEventShortNames[event] ?? event,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                desc,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    final uri = Uri.parse(link);
                    unawaited(launchUrl(uri, mode: LaunchMode.externalApplication));
                  },
                  child: const Text('查看文档'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}