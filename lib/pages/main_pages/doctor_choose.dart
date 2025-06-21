// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:priem_poliklinika/func/func.dart';

var grad = getGraduation();

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
          return ListView.builder(
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              if (!widget.is_choose) {
                return Column(
                  children: [
                    Row(
                      children: [Image.network(doctor['image_path'])],
                    )
                  ],
                );
              }
              return ListTile(
                minTileHeight: MediaQuery.of(context).size.height * 0.15,
                
                leading: Image.network(
                  doctor['image_path'],
                  height: 250,
                  width: 100,
                  fit: BoxFit.fill,
                ),
                title: Text(doctor['name'] +
                        " " +
                        doctor['patronumic'] +
                        " " +
                        doctor['surname'] ??
                    'Без имени'),
                subtitle: FutureBuilder(
                  future: getGraduation(),
                  builder: (context, snapshot1) {
                    if (snapshot1.connectionState == ConnectionState.waiting) {
                      return const Text('Загрузка...');
                    } else if (snapshot1.hasError) {
                      return Text('Ошибка: ${snapshot1.error}');
                    } else if (!snapshot1.hasData || snapshot1.data == null) {
                      return const Text('Нет данных');
                    }
                    var gradList = snapshot1.data!
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
          );
        },
      ),
    );
  }
}
