import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:priem_poliklinika/func/func.dart';
import 'package:priem_poliklinika/func/supabase_connect.dart';
import 'package:priem_poliklinika/main.dart';
import 'package:priem_poliklinika/pages/board_page/onboarding_page.dart';
import 'package:priem_poliklinika/pages/main_pages/choose_menu.dart';
import 'package:priem_poliklinika/pages/main_pages/navbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

dynamic profileFile;
bool isChanged = false;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Supabase.instance.client.auth.signOut();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const OnboardingPage()));
              },
              icon: Icon(Icons.logout_rounded))
        ],
        title: const Text('Ваша учетная запись'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: () async {
                  final pickedFile = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    final nowUser = await getCurrentUser();
                    final userId = nowUser['id'].toString();
                    final userUuid = nowUser['uuid'].toString();
                    final storage = Supabase.instance.client.storage;
                    final filePath = 'profiles/$userId.png';
                    await storage
                        .from('images')
                        .upload(filePath, File(pickedFile.path),
                            fileOptions: FileOptions(
                              upsert: true,
                            ));
                    log('Image uploaded successfully');
                    await storage.from('images').remove([filePath]);
                    await storage
                        .from('images')
                        .upload(filePath, File(pickedFile.path),
                            fileOptions: FileOptions(
                              upsert: true,
                            ));
                    log('Image uploaded successfully');
                    final publicUrl =
                        await storage.from('images').getPublicUrl(filePath);
                    await supabase
                        .from('user')
                        .update({'profile_page_path': publicUrl.toString()}).eq(
                            'uuid', userUuid);
                    setState(() {
                      isChanged = true;
                      localProfileFile = File(pickedFile.path);
                    });
                  }
                },
                child: localProfileFile != null
                    ? Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(150),
                          image: DecorationImage(
                            image: FileImage(localProfileFile!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : FutureBuilder<String>(
                        future: get_profile_page_path(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError || !snapshot.hasData) {
                            return Icon(Icons.error);
                          } else {
                            return Container(
                              height: 150,
                              width: 150,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.blue, width: 2),
                                borderRadius: BorderRadius.circular(150),
                                image: DecorationImage(
                                  image: NetworkImage(snapshot.data!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          }
                        },
                      ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: FutureBuilder<Map<String, dynamic>>(
                future: getCurrentUser(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || !snapshot.hasData) {
                    return const Center(child: Text('Ошибка загрузки данных'));
                  } else {
                    final user = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller:
                              TextEditingController(text: user['name'] ?? ''),
                          decoration: const InputDecoration(
                            labelText: 'Имя',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: TextEditingController(
                              text: user['surname'] ?? ''),
                          decoration: const InputDecoration(
                            labelText: 'Фамилия',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: TextEditingController(
                              text: user['patronumic'] ?? ''),
                          decoration: const InputDecoration(
                            labelText: 'Отчество',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: FutureBuilder(
                  future: getAboutUser(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      // Если данных нет, создаём пустую структуру для заполнения
                      final aboutUser = snapshot.data ?? {};

                      final bloodTypes = ['A(I)', 'B(II)', 'AB(III)', 'O(IV)'];
                      final rhFactors = ['Положительная', 'Отрицательная'];

                      final bloodTypeController = TextEditingController(
                          text: aboutUser['blood_type'] ?? '');
                      final rhFactorController = TextEditingController(
                          text: aboutUser['rh_factor'] ?? '');
                      final omsController =
                          TextEditingController(text: aboutUser['oms'] ?? '');
                      final dmsController =
                          TextEditingController(text: aboutUser['dms'] ?? '');
                      final passportSeriesController = TextEditingController(
                          text: aboutUser['passport_series'].toString() ?? '');
                      final passportNumberController = TextEditingController(
                          text: aboutUser['pasport_number'].toString() ?? '');
                      final addressController = TextEditingController(
                          text: aboutUser['adress'] ?? '');

                      String? validateOms(String? value) {
                        if (value == null || value.isEmpty)
                          return 'Введите номер ОМС';
                        if (!RegExp(r'^\d{16}$').hasMatch(value))
                          return 'ОМС должен содержать 16 цифр';
                        return null;
                      }

                      String? validateDms(String? value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            !RegExp(r'^\d{6,16}$').hasMatch(value)) {
                          return 'ДМС должен содержать от 6 до 16 цифр';
                        }
                        return null;
                      }

                      String? validatePassportSeries(String? value) {
                        if (value == null || value.isEmpty)
                          return 'Введите серию паспорта';
                        if (!RegExp(r'^\d{4}$').hasMatch(value))
                          return 'Серия паспорта должна содержать 4 цифры';
                        return null;
                      }

                      String? validatePassportNumber(String? value) {
                        if (value == null || value.isEmpty)
                          return 'Введите номер паспорта';
                        if (!RegExp(r'^\d{6}$').hasMatch(value))
                          return 'Номер паспорта должен содержать 6 цифр';
                        return null;
                      }

                      String? validateAddress(String? value) {
                        if (value == null || value.isEmpty)
                          return 'Введите адрес';
                        return null;
                      }

                      // Для новых пользователей значения будут пустыми
                      String? selectedBloodType =
                          bloodTypes.contains(aboutUser['blood_type'])
                              ? aboutUser['blood_type']
                              : null;
                      String? selectedRhFactor =
                          rhFactors.contains(aboutUser['rh_factor'])
                              ? aboutUser['rh_factor']
                              : null;

                      return Form(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<String>(
                              value: selectedBloodType,
                              items: bloodTypes
                                  .map((type) => DropdownMenuItem(
                                      value: type, child: Text(type)))
                                  .toList(),
                              onChanged: (val) {
                                selectedBloodType = val;
                                bloodTypeController.text = val ?? '';
                              },
                              decoration: const InputDecoration(
                                labelText: 'Группа крови',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: selectedRhFactor,
                              items: rhFactors
                                  .map((factor) => DropdownMenuItem(
                                      value: factor, child: Text(factor)))
                                  .toList(),
                              onChanged: (val) {
                                selectedRhFactor = val;
                                rhFactorController.text = val ?? '';
                              },
                              decoration: const InputDecoration(
                                labelText: 'Резус-фактор',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: omsController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'ОМС',
                                border: OutlineInputBorder(),
                              ),
                              validator: validateOms,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: dmsController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'ДМС (если есть)',
                                border: OutlineInputBorder(),
                              ),
                              validator: validateDms,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: passportSeriesController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Серия паспорта',
                                border: OutlineInputBorder(),
                              ),
                              validator: validatePassportSeries,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: passportNumberController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Номер паспорта',
                                border: OutlineInputBorder(),
                              ),
                              validator: validatePassportNumber,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: addressController,
                              decoration: const InputDecoration(
                                labelText: 'Адрес',
                                border: OutlineInputBorder(),
                              ),
                              validator: validateAddress,
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: ElevatedButton(
                                onPressed: () async {
                                  // Simple validation
                                  if (validateOms(omsController.text) != null ||
                                      validateDms(dmsController.text) != null ||
                                      validatePassportSeries(
                                              passportSeriesController.text) !=
                                          null ||
                                      validatePassportNumber(
                                              passportNumberController.text) !=
                                          null ||
                                      validateAddress(addressController.text) !=
                                          null ||
                                      (selectedBloodType == null ||
                                          selectedRhFactor == null)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Проверьте правильность заполнения полей')),
                                    );
                                    return;
                                  }

                                  // Mapping for blood type and rh factor to ID
                                  final bloodTypeRhMapping = [
                                    {
                                      'id': 1,
                                      'type_blood': 'A(I)',
                                      'neg_or_pos': 'Отрицательная'
                                    },
                                    {
                                      'id': 2,
                                      'type_blood': 'A(I)',
                                      'neg_or_pos': 'Положительная'
                                    },
                                    {
                                      'id': 3,
                                      'type_blood': 'B(II)',
                                      'neg_or_pos': 'Отрицательная'
                                    },
                                    {
                                      'id': 4,
                                      'type_blood': 'B(II)',
                                      'neg_or_pos': 'Положительная'
                                    },
                                    {
                                      'id': 5,
                                      'type_blood': 'AB(III)',
                                      'neg_or_pos': 'Положительная'
                                    },
                                    {
                                      'id': 6,
                                      'type_blood': 'AB(III)',
                                      'neg_or_pos': 'Отрицательная'
                                    },
                                    {
                                      'id': 7,
                                      'type_blood': 'O(IV)',
                                      'neg_or_pos': 'Положительная'
                                    },
                                    {
                                      'id': 8,
                                      'type_blood': 'O(IV)',
                                      'neg_or_pos': 'Отрицательная'
                                    },
                                  ];

                                  final bloodTypeId =
                                      bloodTypeRhMapping.firstWhere(
                                    (item) =>
                                        item['type_blood'] ==
                                            selectedBloodType &&
                                        item['neg_or_pos'] == selectedRhFactor,
                                    orElse: () => {'id': -1},
                                  )['id'];

                                  if (bloodTypeId == -1) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Выберите корректную группу крови и резус-фактор')),
                                    );
                                    return;
                                  }
                                  final nowUser = await getCurrentUser();
                                  final userUuid = nowUser['id'].toString();

                                  await supabase.from('about_user').upsert({
                                    'id': userUuid,
                                    'group_blood': bloodTypeId,
                                    'oms': omsController.text,
                                    'dms': dmsController.text,
                                    'passport_series': int.parse(
                                        passportSeriesController.text),
                                    'pasport_number': int.parse(
                                        passportNumberController.text),
                                    'adress': addressController.text,
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Данные успешно сохранены')),
                                  );
                                },
                                child: const Text('Сохранить'),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  }),
            )
          ],
        ),
      ),
    );
  }
}
