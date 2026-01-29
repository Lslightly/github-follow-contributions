import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';

class EventFilterWidget extends StatelessWidget {
  const EventFilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '事件类型筛选',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () => eventProvider.setAllEventsSelected(true),
                    child: const Text('全选', style: TextStyle(fontSize: 12)),
                  ),
                  TextButton(
                    onPressed: () => eventProvider.setAllEventsSelected(false),
                    child: const Text('全不选', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: eventProvider.eventTypes.map((eventType) {
              final isSelected = eventProvider.selectedEventTypes.contains(eventType);
              final style = eventProvider.enumEventTypeStyles[eventType];
              final backgroundColor = _hexToColor(style?['backgroundColor']) ?? Colors.grey[200]!;
              final textColor = _hexToColor(style?['color']) ?? Colors.black87;
              
              return FilterChip(
                label: Text(
                  eventProvider.enumEventShortNames[eventType] ?? eventType,
                  style: TextStyle(
                    color: isSelected ? textColor : Colors.black87,
                    fontSize: 12,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => eventProvider.toggleEventType(eventType),
                backgroundColor: backgroundColor.withValues(alpha: 0.3),
                selectedColor: backgroundColor,
                checkmarkColor: textColor,
                side: BorderSide(
                  color: isSelected ? textColor.withValues(alpha: 0.5) : Colors.grey[300]!,
                  width: 1,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              );
            }).toList(),
          ),
        ],
      ),
    );
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