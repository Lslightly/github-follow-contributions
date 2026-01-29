class EventData {
  final String username;
  final List<List<dynamic>> events;
  final Map<String, String> summaryTopics;

  EventData({
    required this.username,
    required this.events,
    required this.summaryTopics,
  });

  factory EventData.fromJson(Map<String, dynamic> json) {
    return EventData(
      username: json['username'],
      events: List<List<dynamic>>.from(json['events'].map((event) => List<dynamic>.from(event))),
      summaryTopics: Map<String, String>.from(json['summary_topics']),
    );
  }
}