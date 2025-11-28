// Models/TicketModel.dart

import 'dart:convert';

TicketEntry ticketEntryFromJson(String str) => TicketEntry.fromJson(json.decode(str));

String ticketEntryToJson(TicketEntry data) => json.encode(data.toJson());

class TicketEntry {
    List<Ticket> tickets;

    TicketEntry({
        required this.tickets,
    });

    factory TicketEntry.fromJson(Map<String, dynamic> json) => TicketEntry(
        tickets: List<Ticket>.from(json["tickets"].map((x) => Ticket.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "tickets": List<dynamic>.from(tickets.map((x) => x.toJson())),
    };
}

class Ticket {
    int id;
    String eventTitle;
    String ticketType;
    double price; 
    int available;
    String eventId;
    bool canEdit;

    Ticket({
        required this.id,
        required this.eventTitle,
        required this.ticketType,
        required this.price,
        required this.available,
        required this.eventId,
        required this.canEdit,
    });

    factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
        id: json["id"],
        eventTitle: json["event_title"],
        ticketType: json["ticket_type"],
        price: (json["price"] as num).toDouble(), 
        available: json["available"],
        eventId: json["event_id"].toString(), 
        //  Jika null, anggap false
        canEdit: json["can_edit"] ?? false, 
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "event_title": eventTitle,
        "ticket_type": ticketType,
        "price": price,
        "available": available,
        "event_id": eventId,
        "can_edit": canEdit,
    };
}