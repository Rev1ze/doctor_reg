import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DoctorBookingPage extends StatefulWidget {
  final String doctorId;
  final String userId;

  const DoctorBookingPage({
    super.key,
    required this.doctorId,
    required this.userId,
  });

  @override
  State<DoctorBookingPage> createState() => _DoctorBookingPageState();
}

class _DoctorBookingPageState extends State<DoctorBookingPage> {
  DateTime? _selectedDate;
  String? _selectedSlot;
  List<Map<String, dynamic>> _workingDays = [];
  List<String> _availableSlots = [];

  @override
  void initState() {
    super.initState();
    _loadWorkingDays();
  }

  Future<void> _loadWorkingDays() async {
    final now = DateTime.now();
    final response = await Supabase.instance.client
        .from('working_days')
        .select()
        .eq('doctor_id', widget.doctorId)
        .gte('date', now.toIso8601String())
        .order('date', ascending: true);

    if (response.isEmpty) {
      return;
    }

    setState(() {
      _workingDays = List<Map<String, dynamic>>.from(response);
    });
  }

  void _updateAvailableSlots(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    final dayData = _workingDays.firstWhere(
      (e) => e['date'].startsWith(dateStr),
      orElse: () => {},
    );

    if (dayData.isEmpty) {
      setState(() => _availableSlots = []);
      return;
    }

    final start = dayData['time_start']; // "08:00"
    final end = dayData['time_end']; // "16:00"

    final slots = _generateTimeSlots(start, end, const Duration(minutes: 15));
    setState(() {
      _availableSlots = slots;
      _selectedSlot = null;
    });
  }

  List<String> _generateTimeSlots(String start, String end, Duration step) {
    final startParts = start.split(':');
    final endParts = end.split(':');

    final startTime =
        DateTime(0, 1, 1, int.parse(startParts[0]), int.parse(startParts[1]));
    final endTime =
        DateTime(0, 1, 1, int.parse(endParts[0]), int.parse(endParts[1]));

    final slots = <String>[];
    var current = startTime;

    while (current.isBefore(endTime)) {
      slots.add(DateFormat('HH:mm').format(current));
      current = current.add(step);
    }

    return slots;
  }

  Future<void> _bookAppointment() async {
    if (_selectedDate == null || _selectedSlot == null) return;

    final response =
        await Supabase.instance.client.from('appointments').insert({
      'doctor_id': widget.doctorId,
      'patient_id': widget.userId,
      'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
      'time': _selectedSlot,
    });

    if (response.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${response.error!.message}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Вы успешно записались')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableDates =
        _workingDays.map((e) => DateTime.parse(e['date'])).toSet();

    return Scaffold(
      appBar: AppBar(title: const Text('Запись к врачу')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Выберите дату:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            CalendarDatePicker(
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 30)),
              onDateChanged: (date) {
                setState(() => _selectedDate = date);
                _updateAvailableSlots(date);
              },
              selectableDayPredicate: (date) {
                return availableDates.contains(
                  DateTime(date.year, date.month, date.day),
                );
              },
            ),
            const SizedBox(height: 20),
            if (_availableSlots.isNotEmpty) ...[
              const Text('Выберите время:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: _availableSlots.map((slot) {
                  return ChoiceChip(
                    label: Text(slot),
                    selected: _selectedSlot == slot,
                    onSelected: (_) => setState(() => _selectedSlot = slot),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _selectedSlot != null ? _bookAppointment : null,
                child: const Text('Записаться'),
              ),
            ] else if (_selectedDate != null)
              const Text('Нет доступного времени на выбранную дату'),
          ],
        ),
      ),
    );
  }
}
