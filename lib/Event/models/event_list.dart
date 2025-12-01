// To parse this JSON data, do
//
//     final eventEntry = eventEntryFromJson(jsonString);

import 'dart:convert';

EventEntry eventEntryFromJson(String str) =>
    EventEntry.fromJson(json.decode(str));

String eventEntryToJson(EventEntry data) => json.encode(data.toJson());

class EventEntry {
  List<Event> upcomingEvents;
  List<Event> pastEvents;

  EventEntry({required this.upcomingEvents, required this.pastEvents});

  factory EventEntry.fromJson(Map<String, dynamic> json) => EventEntry(
    upcomingEvents: List<Event>.from(
      json["upcoming_events"].map((x) => Event.fromJson(x)),
    ),
    pastEvents: List<Event>.from(
      json["past_events"].map((x) => Event.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "upcoming_events": List<dynamic>.from(
      upcomingEvents.map((x) => x.toJson()),
    ),
    "past_events": List<dynamic>.from(pastEvents.map((x) => x.toJson())),
  };
}

class Event {
  String id;
  String judul;
  String lokasi;
  String kategoriDisplay;
  String dateFormatted;
  String detailUrl;
  int? userId;

  Event({
    required this.id,
    required this.judul,
    required this.lokasi,
    required this.kategoriDisplay,
    required this.dateFormatted,
    required this.detailUrl,
    required this.userId,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
    id: json["id"],
    judul: json["judul"],
    lokasi: json["lokasi"],
    kategoriDisplay: json["kategori_display"],
    dateFormatted: json["date_formatted"],
    detailUrl: json["detail_url"],
    userId: json["user_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "judul": judul,
    "lokasi": lokasi,
    "kategori_display": kategoriDisplay,
    "date_formatted": dateFormatted,
    "detail_url": detailUrl,
    "user_id": userId,
  };
}
