import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:priem_poliklinika/func/func.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MyAppointmentsPage extends StatefulWidget {
  const MyAppointmentsPage({super.key});

  @override
  State<MyAppointmentsPage> createState() => _MyAppointmentsPageState();
}

class _MyAppointmentsPageState extends State<MyAppointmentsPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> appointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAppointments();
  }

  Future<void> loadAppointments() async {
    setState(() {
      isLoading = true;
    });

    try {
      final user = await getCurrentUser();
      final userId = user['id'];

      if (userId == null) throw Exception("User not logged in");

      // Выбираем дату и время, врача и клинику
      final response = await supabase.from('appointments').select('''
            id,
            date,
            time,
            doctor_id (
              id,
              name,
              surname
            ),
            clinic_id (
              name_clinic,
              address
            )
          ''').eq('patient_id', userId);

      final doctorIds =
          response.map((e) => e['doctor_id']['id']).toSet().toList();

      final graduations = await supabase
          .from('doctor_graduation')
          .select('graduation, doctor_id')
          .inFilter('doctor_id', doctorIds);

      final graduationMap = <String, List<String>>{};
      for (final g in graduations) {
        final id = g['doctor_id'].toString();
        graduationMap.putIfAbsent(id, () => []).add(g['graduation']);
      }

      for (final appointment in response) {
        final doctor = appointment['doctor_id'];
        final docId = doctor['id'].toString();
        doctor['graduations'] = graduationMap[docId] ?? [];
      }

      if (mounted) {
        setState(() {
          appointments = response;
          isLoading = false;
        });
      }
    } catch (e) {
      log('Ошибка загрузки записей: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void openMapWithAddress(String address) async {
    final query = Uri.encodeComponent(address);
    final url =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои записи')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final item = appointments[index];
                final doctor = item['doctor_id'];
                final clinic = item['clinic_id'];

                final fullName = '${doctor['surname']} ${doctor['name']}';
                final graduation = (doctor['graduations'] as List).join(', ');

                final address = clinic['address'];
                final clinicName = clinic['name_clinic'];

                // Дата и время из строк
                final dateStr =
                    item['date'] as String?; // например "2025-06-23"
                final timeStr = item['time'] as String?; // например "14:30:00"

                DateTime? appointmentDateTime;
                String statusText = '';

                if (dateStr != null && timeStr != null) {
                  appointmentDateTime = DateTime.tryParse('$dateStr $timeStr');
                  if (appointmentDateTime != null) {
                    final now = DateTime.now();
                    if (appointmentDateTime.isBefore(now)) {
                      statusText = 'Запись прошла';
                    } else {
                      statusText = 'Запись запланирована';
                    }
                  }
                }

                final displayDateTime = appointmentDateTime != null
                    ? '${appointmentDateTime.day.toString().padLeft(2, '0')}.'
                        '${appointmentDateTime.month.toString().padLeft(2, '0')}.'
                        '${appointmentDateTime.year} '
                        '${appointmentDateTime.hour.toString().padLeft(2, '0')}:'
                        '${appointmentDateTime.minute.toString().padLeft(2, '0')}'
                    : 'Дата и время не указаны';

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 6.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Врач: $fullName',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          if (graduation.isNotEmpty)
                            Text('Образование: $graduation',
                                style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 8),
                          Text('Клиника: $clinicName',
                              style: const TextStyle(fontSize: 14)),
                          Text('Адрес: $address',
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 8),
                          Text('Время: $displayDateTime',
                              style: const TextStyle(fontSize: 14)),
                          Text(statusText,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: statusText == 'Запись прошла'
                                      ? Colors.red
                                      : Colors.green)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => openMapWithAddress(address),
                            child: const Text('Посмотреть на карте'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
