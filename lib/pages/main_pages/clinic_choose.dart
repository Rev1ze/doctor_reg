import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:priem_poliklinika/func/func.dart';
import 'package:priem_poliklinika/pages/main_pages/doctor_choose.dart';

class ClinicChoose extends StatefulWidget {
  final bool is_choose;
  final String userId;
  const ClinicChoose(
      {super.key, required this.is_choose, required String this.userId});

  @override
  State<ClinicChoose> createState() => _ClinicChooseState();
}

int today = DateTime.now().weekday;

class _ClinicChooseState extends State<ClinicChoose> {
  final Map<int, String> daysShort = {
    DateTime.monday: 'Пн',
    DateTime.tuesday: 'Вт',
    DateTime.wednesday: 'Ср',
    DateTime.thursday: 'Чт',
    DateTime.friday: 'Пт',
    DateTime.saturday: 'Сб',
    DateTime.sunday: 'Вс',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Выбор клиники"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          !widget.is_choose
              ? Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: daysShort.entries.map((entry) {
                    final isSelected = today == entry.key;
                    return ChoiceChip(
                      label: Text(entry.value),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          today = entry.key;
                        });
                      },
                      selectedColor: Colors.blue,
                      backgroundColor: Colors.grey[300],
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList(),
                )
              : Text(''),
          const SizedBox(height: 15),
          Expanded(
            child: FutureBuilder(
              future: getClinic(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Произошла ошибка'));
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Клиники не найдены'));
                }

                final clinics = snapshot.data!;
                final daysInRussian = {
                  DateTime.monday: 'Понедельник',
                  DateTime.tuesday: 'Вторник',
                  DateTime.wednesday: 'Среда',
                  DateTime.thursday: 'Четверг',
                  DateTime.friday: 'Пятница',
                  DateTime.saturday: 'Суббота',
                  DateTime.sunday: 'Воскресенье',
                };
                final todayName = daysInRussian[today];

                return ListView.separated(
                  padding: const EdgeInsets.all(8),
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemCount: clinics.length,
                  itemBuilder: (context, index) {
                    final clinic = clinics[index];
                    final workSchedule =
                        Map<String, dynamic>.from(clinic['work_schedule']);
                    final open = workSchedule[todayName]?['open'];
                    final close = workSchedule[todayName]?['close'];
                    final hours = (open == null || close == null)
                        ? "Не работает"
                        : "С $open до $close";

                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: ListTile(
                        onTap: () {
                          if (widget.is_choose) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DoctorChoose(
                                  clinicId: clinic['id'],
                                  isChoose: false,
                                  userId: (widget.userId),
                                ),
                              ),
                            );
                          } else {
                            openMapWithAddress(clinic['address'], context);
                          }
                        },
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.blue.shade100,
                          child: Icon(Icons.local_hospital,
                              color: Colors.blue.shade900),
                        ),
                        title: Text(
                          clinic['name_clinic'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text("Адрес: ${clinic['address']}"),
                            const SizedBox(height: 2),
                            Text(hours,
                                style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                        trailing: widget.is_choose
                            ? const Icon(Icons.arrow_forward_ios)
                            : const Icon(Icons.map),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
