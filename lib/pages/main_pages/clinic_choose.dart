// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:priem_poliklinika/func/func.dart';

class ClinicChoose extends StatefulWidget {
  const ClinicChoose({super.key});

  @override
  State<ClinicChoose> createState() => _ClinicChooseState();
}

int today = DateTime.now().weekday;

class _ClinicChooseState extends State<ClinicChoose> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Клиники"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Wrap(
              runSpacing: 5,
              children: [
                ElevatedButton(
                    style: ButtonStyle(
                        shape: WidgetStateProperty.all(CircleBorder()),
                        padding: WidgetStateProperty.all(EdgeInsets.all(10)),
                        backgroundColor: WidgetStateProperty.all(Colors.blue)),
                    onPressed: () {
                      setState(() {
                        today = DateTime.monday;
                      });
                    },
                    child: Text(
                      "Пн",
                      style: TextStyle(color: Colors.black),
                    )),
                ElevatedButton(
                    style: ButtonStyle(
                        shape: WidgetStateProperty.all(CircleBorder()),
                        padding: WidgetStateProperty.all(EdgeInsets.all(10)),
                        backgroundColor: WidgetStateProperty.all(Colors.blue)),
                    onPressed: () {
                      setState(() {
                        today = DateTime.tuesday;
                      });
                    },
                    child: Text("Вт", style: TextStyle(color: Colors.black))),
                ElevatedButton(
                    style: ButtonStyle(
                        shape: WidgetStateProperty.all(CircleBorder()),
                        padding: WidgetStateProperty.all(EdgeInsets.all(10)),
                        backgroundColor: WidgetStateProperty.all(Colors.blue)),
                    onPressed: () {
                      setState(() {
                        today = DateTime.wednesday;
                      });
                    },
                    child: Text("Ср", style: TextStyle(color: Colors.black))),
                ElevatedButton(
                    style: ButtonStyle(
                        shape: WidgetStateProperty.all(CircleBorder()),
                        padding: WidgetStateProperty.all(EdgeInsets.all(10)),
                        backgroundColor: WidgetStateProperty.all(Colors.blue)),
                    onPressed: () {
                      setState(() {
                        today = DateTime.thursday;
                      });
                    },
                    child: Text("Чт", style: TextStyle(color: Colors.black))),
                ElevatedButton(
                    style: ButtonStyle(
                        shape: WidgetStateProperty.all(CircleBorder()),
                        padding: WidgetStateProperty.all(EdgeInsets.all(10)),
                        backgroundColor: WidgetStateProperty.all(Colors.blue)),
                    onPressed: () {
                      setState(() {
                        today = DateTime.friday;
                      });
                    },
                    child: Text("Пт", style: TextStyle(color: Colors.black))),
                ElevatedButton(
                    style: ButtonStyle(
                        shape: WidgetStateProperty.all(CircleBorder()),
                        padding: WidgetStateProperty.all(EdgeInsets.all(10)),
                        backgroundColor: WidgetStateProperty.all(Colors.blue)),
                    onPressed: () {
                      setState(() {
                        today = DateTime.saturday;
                      });
                    },
                    child: Text("Сб", style: TextStyle(color: Colors.black))),
                ElevatedButton(
                    style: ButtonStyle(
                        shape: WidgetStateProperty.all(CircleBorder()),
                        padding: WidgetStateProperty.all(EdgeInsets.all(10)),
                        backgroundColor: WidgetStateProperty.all(Colors.blue)),
                    onPressed: () {
                      setState(() {
                        today = DateTime.sunday;
                      });
                    },
                    child: Text("Вс", style: TextStyle(color: Colors.black))),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            FutureBuilder(
                future: getClinic(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Произошла ошибка');
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: const CircularProgressIndicator());
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Доктора не найдены'));
                  }
                  final clinics = snapshot.data!;
                  return ListView.separated(
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      color: Colors.black,
                    ),
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: clinics.length,
                    itemBuilder: (BuildContext context, int index) {
                      final clinic = clinics[index];
                      final Map<String, dynamic> workSchedule =
                          Map<String, dynamic>.from(clinic['work_schedule']);
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
                      dynamic workHours;
                      workHours = workSchedule[todayName]?['open'];
                      if (workHours == null ||
                          workSchedule[todayName]['close'] == null) {
                        workHours = "Не работает";
                      } else {
                        workHours = "Часы работы\n" +
                            workHours +
                            " - " +
                            workSchedule[todayName]?['close'];
                      }
                      return ListTile(
                          minLeadingWidth: 78,
                          onTap: () {},
                          subtitle: Text(
                              "Адрес мед. учреждения: " + clinic['address']),
                          title: Text(clinic['name_clinic']),
                          leading: Text(workHours));
                    },
                  );
                }),
          ],
        ),
      ),
    );
  }
}
