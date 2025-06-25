import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:priem_poliklinika/pages/auth_reg/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DoctorAppointmentsPage extends StatefulWidget {
  final int doctorId;

  const DoctorAppointmentsPage({super.key, required this.doctorId});

  @override
  State<DoctorAppointmentsPage> createState() => _DoctorAppointmentsPageState();
}

class _DoctorAppointmentsPageState extends State<DoctorAppointmentsPage> {
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      final response = await Supabase.instance.client
          .from('appointments')
          .select('*, user(name)')
          .eq('doctor_id', widget.doctorId)
          .order('date', ascending: true)
          .order('time', ascending: true);

      setState(() {
        _appointments = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Ошибка загрузки: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _completeAppointment(int appointmentId) async {
    try {
      await Supabase.instance.client
          .from('appointments')
          .update({'status': 'completed'}).eq('id', appointmentId);

      _fetchAppointments(); // Обновить список
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка завершения приёма: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои приёмы'),
        backgroundColor: Colors.blue,
        centerTitle: true,
        automaticallyImplyLeading: false, // отключает стрелку назад
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти из аккаунта',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Выход'),
                  content: const Text('Вы точно хотите выйти из аккаунта?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Отмена'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Выйти'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const UnifiedLoginPage()));
                  // Или, если у тебя есть конкретный виджет:
                  // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
                }
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = _appointments[index];
                    final patient = appointment['user'];
                    final dateStr = appointment['date'];
                    final timeStr = appointment['time'];
                    final status = appointment['status'];
                    final appointmentId = appointment['id'];

                    DateTime? appointmentDateTime;
                    try {
                      appointmentDateTime = DateTime.parse('$dateStr $timeStr');
                    } catch (_) {
                      appointmentDateTime = null;
                    }

                    final hasPassed = appointmentDateTime != null &&
                        appointmentDateTime.isBefore(now);

                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Пациент: ${patient['name']}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                                'Дата: ${DateFormat('dd.MM.yyyy').format(DateTime.parse(dateStr))}'),
                            Text('Время: ${timeStr.substring(0, 5)}'),
                            const SizedBox(height: 10),
                            if (status == 'completed' || hasPassed)
                              Text(
                                '✅ Приём завершён',
                                style: TextStyle(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500),
                              )
                            else
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '🕒 Ожидается приём',
                                    style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        _completeAppointment(appointmentId),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    child: const Text('Завершить'),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
