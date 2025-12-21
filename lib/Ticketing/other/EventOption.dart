class EventOption {
  final String id;
  final String title;

  EventOption({required this.id, required this.title});

  factory EventOption.fromJson(Map<String, dynamic> json) {
    return EventOption(id: json['id'].toString(), title: json['title']);
  }
}