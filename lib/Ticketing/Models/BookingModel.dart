// To parse this JSON data, do
//
//     final bookingEntry = bookingEntryFromJson(jsonString);

import 'dart:convert';

BookingEntry bookingEntryFromJson(String str) => BookingEntry.fromJson(json.decode(str));

String bookingEntryToJson(BookingEntry data) => json.encode(data.toJson());

class BookingEntry {
    List<Booking> bookings;

    BookingEntry({
        required this.bookings,
    });

    factory BookingEntry.fromJson(Map<String, dynamic> json) => BookingEntry(
        bookings: List<Booking>.from(json["bookings"].map((x) => Booking.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "bookings": List<dynamic>.from(bookings.map((x) => x.toJson())),
    };
}

class Booking {
    int id;
    String eventId;
    String eventTitle;
    String date;
    String location;
    int quantity;
    int totalPrice;
    String ticketType;
    String bookedAt;
    String eventUrl;

    Booking({
        required this.id,
        required this.eventId,
        required this.eventTitle,
        required this.date,
        required this.location,
        required this.quantity,
        required this.totalPrice,
        required this.ticketType,
        required this.bookedAt,
        required this.eventUrl,
    });

    factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json["id"],
        eventId: json["event_id"],
        eventTitle: json["event_title"],
        date: json["date"],
        location: json["location"],
        quantity: json["quantity"],
        totalPrice: json["total_price"],
        ticketType: json["ticket_type"],
        bookedAt: json["booked_at"],
        eventUrl: json["event_url"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "event_id": eventId,
        "event_title": eventTitle,
        "date": date,
        "location": location,
        "quantity": quantity,
        "total_price": totalPrice,
        "ticket_type": ticketType,
        "booked_at": bookedAt,
        "event_url": eventUrl,
    };
}
