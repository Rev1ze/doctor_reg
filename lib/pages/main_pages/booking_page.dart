import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class BookingPage extends StatefulWidget {
  final int doctorId;
  final int userId;
  final int clinicId;

  const BookingPage(
      {super.key,
      required this.doctorId,
      required this.userId,
      required this.clinicId});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  Map<DateTime, List<Map<String, dynamic>>> groupedSlots = {};
  DateTime? selectedDate;
  String? selectedTime;

  @override
  void initState() {
    super.initState();
    fetchAvailableSlots();
  }

  Future<void> fetchAvailableSlots() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final response = await supabase
        .from('working_days')
        .select()
        .eq('doctor_id', widget.doctorId)
        .eq('clinic_id', widget.clinicId)
        .gte('date', DateTime.now().toIso8601String().substring(0, 10))
        .order('date', ascending: true);

    final data = response as List<dynamic>;
    Map<DateTime, List<Map<String, dynamic>>> slotMap = {};

    for (var day in data) {
      DateTime date = DateTime.parse(day['date']);
      TimeOfDay start = _parseTime(day['time_start']);
      TimeOfDay end = _parseTime(day['time_end']);

      List<Map<String, dynamic>> slots = [];

      for (var t = start;
          _timeToMinutes(t) < _timeToMinutes(end);
          t = _addMinutes(t, 15)) {
        String timeStr = _formatTime(t);

        final existing = await supabase
            .from('appointments')
            .select()
            .eq('doctor_id', widget.doctorId)
            .eq('date', date.toIso8601String().substring(0, 10))
            .eq('time', timeStr);

        bool isFree = (existing as List).isEmpty;
        slots.add({
          'time': timeStr,
          'isFree': isFree,
        });
      }

      if (slots.isNotEmpty) {
        slotMap[date] = slots;
      }
    }

    if (mounted) {
      setState(() {
        groupedSlots = slotMap;
        _isLoading = false;
      });
    }
  }

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  int _timeToMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  TimeOfDay _addMinutes(TimeOfDay time, int minutes) {
    final total = _timeToMinutes(time) + minutes;
    return TimeOfDay(hour: total ~/ 60, minute: total % 60);
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> bookAppointment() async {
    if (selectedDate == null || selectedTime == null) return;

    await supabase.from('appointments').insert({
      'doctor_id': widget.doctorId,
      'patient_id': widget.userId + 1,
      'date': selectedDate!.toIso8601String().substring(0, 10),
      'time': selectedTime!,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Запись успешно создана!")),
    );

    setState(() {
      selectedDate = null;
      selectedTime = null;
    });

    fetchAvailableSlots(); // Обновим слоты
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Запись к врачу')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : groupedSlots.isEmpty
              ? const Center(
                  child: Text(
                      'К данному врачу в этой клинике нет доступных записей ближайшее время'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          children: groupedSlots.entries.map((entry) {
                            final date = entry.key;
                            final slots = entry.value;
                            final dateStr =
                                DateFormat('dd.MM.yyyy').format(date);

                            return Container(
                              width: MediaQuery.of(context).size.width * 0.4,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.blue.shade100),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 5,
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    dateStr,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: slots.map((slot) {
                                      final isSelected = selectedDate == date &&
                                          selectedTime == slot['time'];
                                      final isFree = slot['isFree'];

                                      return ChoiceChip(
                                        label: Text(slot['time']),
                                        selected: isSelected,
                                        onSelected: isFree
                                            ? (_) {
                                                setState(() {
                                                  selectedDate = date;
                                                  selectedTime = slot['time'];
                                                });
                                              }
                                            : null,
                                        selectedColor: Colors.green.shade300,
                                        backgroundColor: isFree
                                            ? Colors.green.shade100
                                            : Colors.red,
                                        labelStyle: TextStyle(
                                            color: isFree
                                                ? Colors.black
                                                : Colors.black),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (selectedDate != null && selectedTime != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ElevatedButton(
                            onPressed: bookAppointment,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                            ),
                            child: const Text('Записаться на приём'),
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
    );
  }
}
