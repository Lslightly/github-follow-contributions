import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';

class LegendWidget extends StatelessWidget {
  const LegendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    
    return Container(
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
          ...eventProvider.topicCategories.entries.map((entry) => 
            Padding(
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
                      children: entry.value.map((event) => 
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getEventBackgroundColor(context, eventProvider, event),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getEventBorderColor(context, eventProvider, event),
                            ),
                          ),
                          child: Text(
                            eventProvider.enumEventShortNames[event] ?? event,
                            style: TextStyle(
                              color: _getEventTextColor(context, eventProvider, event),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              '将鼠标悬浮在tag上以获得总结。',
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

  Color _getEventBackgroundColor(BuildContext context, EventProvider provider, String event) {
    final scheme = Theme.of(context).colorScheme;
    if (provider.topicCategories['work']?.contains(event) == true) {
      return scheme.primaryContainer;
    }
    if (provider.topicCategories['discuss']?.contains(event) == true) {
      return scheme.secondaryContainer;
    }
    if (provider.topicCategories['watch']?.contains(event) == true) {
      return scheme.tertiaryContainer;
    }
    final hex = provider.enumEventTypeStyles[event]?['backgroundColor'];
    return _hexToColor(hex) ?? const Color(0xFFF3F4F6);
  }

  Color _getEventTextColor(BuildContext context, EventProvider provider, String event) {
    final scheme = Theme.of(context).colorScheme;
    if (provider.topicCategories['work']?.contains(event) == true) {
      return scheme.onPrimaryContainer;
    }
    if (provider.topicCategories['discuss']?.contains(event) == true) {
      return scheme.onSecondaryContainer;
    }
    if (provider.topicCategories['watch']?.contains(event) == true) {
      return scheme.onTertiaryContainer;
    }
    final hex = provider.enumEventTypeStyles[event]?['color'];
    return _hexToColor(hex) ?? const Color(0xFF586069);
  }

  Color _getEventBorderColor(BuildContext context, EventProvider provider, String event) {
    final scheme = Theme.of(context).colorScheme;
    if (provider.topicCategories['work']?.contains(event) == true) {
      return scheme.onPrimaryContainer.withValues(alpha: 0.25);
    }
    if (provider.topicCategories['discuss']?.contains(event) == true) {
      return scheme.onSecondaryContainer.withValues(alpha: 0.25);
    }
    if (provider.topicCategories['watch']?.contains(event) == true) {
      return scheme.onTertiaryContainer.withValues(alpha: 0.25);
    }
    final hex = provider.enumEventTypeStyles[event]?['color'];
    final c = _hexToColor(hex);
    if (c == null) return const Color(0xFFE1E4E8);
    return c.withValues(alpha: 0.25);
  }

  Color? _hexToColor(String? hex) {
    if (hex == null) return null;
    var h = hex.replaceAll('#', '');
    if (h.length == 6) h = 'ff$h';
    final v = int.tryParse(h, radix: 16);
    if (v == null) return null;
    return Color(v);
  }
}