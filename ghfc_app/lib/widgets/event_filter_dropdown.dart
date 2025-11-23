import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';

class EventFilterDropdown extends StatefulWidget {
  const EventFilterDropdown({super.key});

  @override
  State<EventFilterDropdown> createState() => _EventFilterDropdownState();
}

class _EventFilterDropdownState extends State<EventFilterDropdown> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '筛选事件',
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.black,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckboxListTile(
                    title: const Text('All'),
                    value: eventProvider.allEventsSelected,
                    onChanged: (value) {
                      eventProvider.setAllEventsSelected(value ?? false);
                    },
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(height: 1),
                  ...eventProvider.eventTypes.map((eventType) => 
                    CheckboxListTile(
                      title: Text(eventProvider.enumEventShortNames[eventType] ?? eventType),
                      value: eventProvider.selectedEventTypes.contains(eventType),
                      onChanged: (value) {
                        eventProvider.toggleEventType(eventType);
                      },
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}