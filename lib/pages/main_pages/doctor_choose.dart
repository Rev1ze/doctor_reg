// // ignore_for_file: prefer_interpolation_to_compose_strings, non_constant_identifier_names

// import 'package:flutter/material.dart';
// import 'package:priem_poliklinika/func/func.dart';

// Future<List<Map<String, dynamic>>> grad = getGraduation();

// class DoctorChoose extends StatefulWidget {
//   final bool is_choose;
//   const DoctorChoose({super.key, required this.is_choose});
//   @override
//   State<DoctorChoose> createState() => _DoctorChooseState();
// }

// class _DoctorChooseState extends State<DoctorChoose> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Выберите доктора"),
//         centerTitle: true,
//         backgroundColor: Colors.blue,
//       ),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: getAllDoctors(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Ошибка: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('Доктора не найдены'));
//           }
//           final doctors = snapshot.data!;
//           return ListView.separated(
//             itemCount: doctors.length,
//             itemBuilder: (context, index) {
//               final doctor = doctors[index];
//               return ListTile(
//                 leading: Image.network(
//                   doctor['image_path'],
//                   height: 100,
//                   width: 70,
//                   fit: BoxFit.fill,
//                 ),
//                 title: Text(doctor['name'] +
//                         " " +
//                         doctor['patronumic'] +
//                         " " +
//                         doctor['surname'] ??
//                     'Без имени'),
//                 // Получаем специализации с помощью FutureBuilder для каждого элемента
//                 subtitle: FutureBuilder<List<Map<String, dynamic>>>(
//                   future: grad,
//                   builder: (context, gradSnapshot) {
//                     if (gradSnapshot.connectionState ==
//                         ConnectionState.waiting) {
//                       return const Text('Загрузка специализаций...');
//                     } else if (gradSnapshot.hasError) {
//                       return Text('Ошибка загрузки специализаций');
//                     } else if (!gradSnapshot.hasData) {
//                       return const Text('Без специализации');
//                     }
//                     var gradList = gradSnapshot.data!
//                         .where(
//                             (element) => element['doctor_id'] == doctor['id'])
//                         .toList();
//                     var gradItog = "";
//                     for (int i = 0; i < gradList.length; i++) {
//                       if (i == gradList.length - 1) {
//                         gradItog += gradList[i]['graduation'].toString();
//                         break;
//                       }
//                       gradItog += gradList[i]['graduation'].toString() + ", ";
//                     }
//                     gradItog += " (${doctor['job_name']})";
//                     return Text(
//                       gradList.isNotEmpty ? gradItog : 'Без специализации',
//                     );
//                   },
//                 ),
//                 onTap: () {
//                   if (widget.is_choose == false) {

//                     return;
//                   }
//                 },
//               );
//             },
//             separatorBuilder: (context, index) => const Divider(
//               color: Colors.black,
//               height: 1,
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class DoctorChoose extends StatefulWidget {
//   final String userId;

//   const DoctorChoose({super.key, required this.userId});

//   @override
//   State<DoctorChoose> createState() => _DoctorChooseState();
// }

// class _DoctorChooseState extends State<DoctorChoose> {
//   List<Map<String, dynamic>> _doctors = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadDoctors();
//   }

//   Future<void> _loadDoctors() async {
//     final response = await Supabase.instance.client.from('doctors').select();

//     if (response.isEmpty) {
//       setState(() {
//         _doctors = [];
//         _isLoading = false;
//       });
//       return;
//     }

//     setState(() {
//       _doctors = List<Map<String, dynamic>>.from(response);
//       _isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Список врачей')),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: _doctors.length,
//               itemBuilder: (context, index) {
//                 final doctor = _doctors[index];
//                 return Card(
//                   margin:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   child: ListTile(
//                     leading: CircleAvatar(
//                       backgroundImage: NetworkImage(doctor['image_url'] ?? ''),
//                       radius: 25,
//                     ),
//                     title: Text(doctor['name'] ?? 'Без имени'),
//                     subtitle: Text(doctor['job'] ?? 'Не указано'),
//                     trailing: ElevatedButton(
//                       onPressed: () {
//                         // Navigator.push(
//                         // context,
//                         // MaterialPageRoute(
//                         //   builder: (_) => DoctorBookingPage(
//                         //     doctorId: doctor['id'].toString(),
//                         //     userId: widget.userId,
//                         //   ),
//                         // ),
//                         // );
//                       },
//                       child: const Text('Записаться'),
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }
import 'dart:developer';

import 'package:age_calculator/age_calculator.dart';
import 'package:flutter/material.dart';
import 'package:priem_poliklinika/pages/main_pages/booking_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'doctor_booking_page.dart';

class DoctorChoose extends StatefulWidget {
  final String userId;
  final bool isChoose;
  final int clinicId;
  const DoctorChoose(
      {super.key,
      required this.userId,
      required this.isChoose,
      required this.clinicId});

  @override
  State<DoctorChoose> createState() => _DoctorChooseState();
}

class _DoctorChooseState extends State<DoctorChoose> {
  List<Map<String, dynamic>> _doctors = [];
  Map<String, List<String>> _doctorGraduations =
      {}; // doctorId -> List<graduation>
  List<String> _allGraduations = [];
  String? _selectedGraduation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDoctorsAndGraduations();
  }

  Future<void> _loadDoctorsAndGraduations() async {
    setState(() => _isLoading = true);

    final doctorsRes = await Supabase.instance.client.from('doctors').select();

    final gradRes = await Supabase.instance.client
        .from('doctor_graduation')
        .select('doctor_id, graduation');

    // Сбор всех специализаций и группировка по doctor_id
    final Map<String, List<String>> docToGrads = {};
    final Set<String> allGradsSet = {};

    for (final item in gradRes) {
      final doctorId = item['doctor_id'].toString();
      final grad = item['graduation']?.toString();
      if (grad != null && grad.isNotEmpty) {
        docToGrads.putIfAbsent(doctorId, () => []).add(grad);
        allGradsSet.add(grad);
      }
    }

    setState(() {
      _doctors = List<Map<String, dynamic>>.from(doctorsRes);
      _doctorGraduations = docToGrads;
      _allGraduations = allGradsSet.toList()..sort();
      _isLoading = false;
    });
  }

  String formatAge(int years) {
    log('форматирование');
    if (years % 10 == 1 && years % 100 != 11) {
      return '$years год';
    } else if ([2, 3, 4].contains(years % 10) &&
        !(years % 100 >= 12 && years % 100 <= 14)) {
      return '$years года';
    } else {
      return '$years лет';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredDoctors = _selectedGraduation == null
        ? _doctors
        : _doctors.where((doc) {
            final docId = doc['id'].toString();
            final grads = _doctorGraduations[docId] ?? [];
            return grads.contains(_selectedGraduation);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Список врачей'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Фильтр по специализации',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedGraduation,
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Все')),
                      ..._allGraduations.map((grad) => DropdownMenuItem(
                            value: grad,
                            child: Text(grad),
                          )),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedGraduation = value),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredDoctors.length,
                    itemBuilder: (context, index) {
                      final doctor = filteredDoctors[index];
                      final docId = doctor['id'].toString();
                      final name = doctor['name'] ?? 'Без имени';
                      final imageUrl = doctor['image_path'] ?? '';
                      final grads =
                          (_doctorGraduations[docId] ?? []).join(', ') +
                              " (${doctor['job_name']})";

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: imageUrl.isNotEmpty
                                  ? NetworkImage(imageUrl)
                                  : null,
                              radius: 25,
                              child: imageUrl.isEmpty
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(name),
                            subtitle: Text(
                                grads.isEmpty ? 'Без специализации' : grads),
                            trailing: !widget.isChoose
                                ? ElevatedButton(
                                    onPressed: () {
                                      if (widget.isChoose == true ||
                                          widget.clinicId == -1) {
                                        return;
                                      }
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => BookingPage(
                                              doctorId: int.parse(docId),
                                              userId:
                                                  int.tryParse(widget.userId) ??
                                                      0,
                                              clinicId: widget.clinicId,
                                              // userId: int.parse(widget.userId),
                                            ),
                                          ));
                                    },
                                    child: const Text('Записаться'),
                                  )
                                : Text(formatAge(AgeCalculator.age(
                                        (DateTime.parse(doctor['birthday'])))
                                    .years))),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
