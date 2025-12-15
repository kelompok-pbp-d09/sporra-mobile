import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:sporra_mobile/event/models/event_entry.dart';

class EventEditPage extends StatefulWidget {
  final Event event;

  const EventEditPage({super.key, required this.event});

  @override
  State<EventEditPage> createState() => _EventEditPageState();
}

class _EventEditPageState extends State<EventEditPage> {
  final _formKey = GlobalKey<FormState>();

  late String _judul;
  late String _deskripsi;
  late String _kategori;
  late String _lokasi;
  late String _date;

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

  @override
  void initState() {
    super.initState();
    _judul = widget.event.judul;
    _deskripsi = widget.event.deskripsi;
    _lokasi = widget.event.lokasi;

    _kategori = _categories.contains(widget.event.kategori.toLowerCase())
        ? widget.event.kategori.toLowerCase()
        : 'others';

    _date = widget.event.dateFormatted.replaceAll(',', '');
  }

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
    if (pickedDate == null) return;

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
    if (pickedTime == null) return;

    setState(() {
      _date = _formatIndoDate(pickedDate, pickedTime);
    });
  }

  Future<void> _submitEdit(CookieRequest request) async {
    final url =
        "https://afero-aqil-sporra.pbp.cs.ui.ac.id/event/edit-event-flutter/${widget.event.id}/";

    final response = await request.post(url, {
      "judul": _judul,
      "deskripsi": _deskripsi,
      "kategori": _kategori,
      "lokasi": _lokasi,
      "date": _date,
    });

    if (!mounted) return;

    if (response["status"] == "error") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["message"]),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Event successfully updated!"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: const Text("Edit Event"),
        backgroundColor: const Color(0xFF1F2937),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const CircleAvatar(
            backgroundColor: Colors.black54,
            child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 12,
            color: const Color(0xFF1F2937),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28.0),
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
                      initialValue: _judul,
                      onSaved: (v) => _judul = v!,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      label: "Description",
                      initialValue: _deskripsi,
                      maxLines: 4,
                      onSaved: (v) => _deskripsi = v!,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      label: "Location",
                      initialValue: _lokasi,
                      onSaved: (v) => _lokasi = v!,
                    ),
                    const SizedBox(height: 20),

                    Text(
                      "Category",
                      style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 16),
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
                                (val) => DropdownMenuItem(
                                  value: val,
                                  child: Text(
                                    val,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) => setState(() => _kategori = val!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      "Date & Time",
                      style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 16),
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
                          _date,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            await _submitEdit(request);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Save Changes",
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
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String initialValue,
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
          initialValue: initialValue,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF374151),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          validator: (v) => v == null || v.isEmpty ? "Required" : null,
          onSaved: onSaved,
        ),
      ],
    );
  }
}
