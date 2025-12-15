import "package:flutter/material.dart";
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class EventFormPage extends StatefulWidget {
  const EventFormPage({super.key});

  @override
  State<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _judul = "";
  String _deskripsi = "";
  String _kategori = "basket";
  String _lokasi = "";
  String _date = "";

  final List<String> _categories = [
    'basket',
    'tennis',
    'bulu tangkis',
    'volley',
    'futsal',
    'sepak bola',
    'renang',
    'lainnya',
  ];

  String _formatIndoDate(DateTime date, TimeOfDay time) {
    const bulanIndo = [
      "",
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember",
    ];
    String day = date.day.toString();
    String month = bulanIndo[date.month];
    String year = date.year.toString();
    String hour = time.hour.toString().padLeft(2, "0");
    String minute = time.minute.toString().padLeft(2, "0");
    return "$day $month $year $hour.$minute";
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      initialDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          dialogBackgroundColor: const Color(0xFF1F2937),
          colorScheme: const ColorScheme.dark(primary: Colors.blue),
        ),
        child: child!,
      ),
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) => Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(primary: Colors.blue),
          ),
          child: child!,
        ),
      );
      if (pickedTime != null) {
        setState(() {
          _date = _formatIndoDate(pickedDate, pickedTime);
        });
      }
    }
  }

  Future<void> _submitEvent(CookieRequest request) async {
    final response = await request.post(
      "https://afero-aqil-sporra.pbp.cs.ui.ac.id/event/create-event-flutter/",
      {
        "judul": _judul,
        "deskripsi": _deskripsi,
        "kategori": _kategori,
        "lokasi": _lokasi,
        "date": _date,
      },
    );
    if (!mounted) return;
    if (response["status"] == "error") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["message"]),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event successfully created!")),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: const Text("Create Event"),
        backgroundColor: const Color(0xFF1F2937),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const CircleAvatar(
            backgroundColor: Colors.black54,
            child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 12,
              color: const Color(0xFF1F2937),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Details",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildInputField(
                        label: "Title",
                        onSaved: (v) => _judul = v!,
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        label: "Description",
                        maxLines: 3,
                        onSaved: (v) => _deskripsi = v!,
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        label: "Location",
                        onSaved: (v) => _lokasi = v!,
                      ),

                      const SizedBox(height: 20),
                      const Text(
                        "Category",
                        style: TextStyle(
                          color: Color(0xFFD1D5DB),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF374151),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            dropdownColor: const Color(0xFF374151),
                            value: _kategori,
                            iconEnabledColor: Colors.white,
                            items: _categories
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(
                                      c,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _kategori = v!),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      const Text(
                        "Date & Time",
                        style: TextStyle(
                          color: Color(0xFFD1D5DB),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF374151),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _date.isEmpty ? "Choose Date & Time" : _date,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              _submitEvent(request);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            "Save Event",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required Function(String?) onSaved,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextFormField(
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF374151),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          validator: (v) => v!.isEmpty ? "Required" : null,
          onSaved: onSaved,
        ),
      ],
    );
  }
}
