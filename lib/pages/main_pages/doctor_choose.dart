// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:priem_poliklinika/func/func.dart';

Future<List<Map<String, dynamic>>> grad = getGraduation();

class DoctorChoose extends StatefulWidget {
  final bool is_choose;
  const DoctorChoose({super.key, required this.is_choose});
  @override
  State<DoctorChoose> createState() => _DoctorChooseState();
}

class _DoctorChooseState extends State<DoctorChoose> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Выберите доктора"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getAllDoctors(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Доктора не найдены'));
          }
          final doctors = snapshot.data!;
          return ListView.separated(
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              return ListTile(
                leading: Image.network(
                  doctor['image_path'],
                  height: 100,
                  width: 70,
                  fit: BoxFit.fill,
                ),
                title: Text(doctor['name'] +
                        " " +
                        doctor['patronumic'] +
                        " " +
                        doctor['surname'] ??
                    'Без имени'),
                // Получаем специализации с помощью FutureBuilder для каждого элемента
                subtitle: FutureBuilder<List<Map<String, dynamic>>>(
                  future: grad,
                  builder: (context, gradSnapshot) {
                    if (gradSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Text('Загрузка специализаций...');
                    } else if (gradSnapshot.hasError) {
                      return Text('Ошибка загрузки специализаций');
                    } else if (!gradSnapshot.hasData) {
                      return const Text('Без специализации');
                    }
                    var gradList = gradSnapshot.data!
                        .where(
                            (element) => element['doctor_id'] == doctor['id'])
                        .toList();
                    var gradItog = "";
                    for (int i = 0; i < gradList.length; i++) {
                      if (i == gradList.length - 1) {
                        gradItog += gradList[i]['graduation'].toString();
                        break;
                      }
                      gradItog += gradList[i]['graduation'].toString() + ", ";
                    }
                    gradItog += " (${doctor['job_name']})";
                    return Text(
                      gradList.isNotEmpty ? gradItog : 'Без специализации',
                    );
                  },
                ),
                onTap: () {
                  if (widget.is_choose == false) {
                    
                    return;
                  }
                },
              );
            },
            separatorBuilder: (context, index) => const Divider(
              color: Colors.black,
              height: 1,
            ),
          );
        },
      ),
    );
  }
}
