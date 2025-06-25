import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:priem_poliklinika/func/func.dart';
import 'package:priem_poliklinika/func/supabase_connect.dart';
import 'package:priem_poliklinika/main.dart';
import 'package:priem_poliklinika/pages/board_page/onboarding_page.dart';
import 'package:priem_poliklinika/pages/main_pages/navbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController nameController;
  late TextEditingController surnameController;
  late TextEditingController patronymicController;

  late TextEditingController omsController;
  late TextEditingController dmsController;
  late TextEditingController passportSeriesController;
  late TextEditingController passportNumberController;
  late TextEditingController addressController;

  final bloodTypes = ['A(I)', 'B(II)', 'AB(III)', 'O(IV)'];
  final rhFactors = ['Положительная', 'Отрицательная'];

  String? selectedBloodType;
  String? selectedRhFactor;

  bool isLoading = true;
  String? profileImageUrl;
  File? localProfileFile;

  final _formKey = GlobalKey<FormState>();

  bool isOmsLocked = false;
  bool isDmsLocked = false;
  bool isNameLocked = false;
  bool isPassportLocked = false;
  bool isBloodGroupLocked = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    surnameController = TextEditingController();
    patronymicController = TextEditingController();
    omsController = TextEditingController();
    dmsController = TextEditingController();
    passportSeriesController = TextEditingController();
    passportNumberController = TextEditingController();
    addressController = TextEditingController();
    if (localProfileFile1 != null) {
      localProfileFile = localProfileFile1;
    }
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await getCurrentUser();
      final aboutUser = await getAboutUser();
      final url = await get_profile_page_path();

      if (!mounted) return;

      final groupBloodId = aboutUser['group_blood'];
      String? bloodType;
      String? rhFactor;

      if (groupBloodId != null) {
        final bloodEntry = _bloodTypeRhMapping.firstWhere(
          (e) => e['id'] == groupBloodId,
          orElse: () => {},
        );
        if (bloodEntry.isNotEmpty) {
          bloodType = bloodEntry['type_blood'];
          rhFactor = bloodEntry['neg_or_pos'];
        }
      }

      setState(() {
        nameController.text = user['name'] ?? '';
        surnameController.text = user['surname'] ?? '';
        patronymicController.text = user['patronymic'] ?? '';

        omsController.text = aboutUser['oms'] ?? '';
        dmsController.text = aboutUser['dms'] ?? '';
        passportSeriesController.text =
            aboutUser['passport_series']?.toString() ?? '';
        passportNumberController.text =
            aboutUser['pasport_number']?.toString() ?? '';
        addressController.text = aboutUser['adress'] ?? '';

        profileImageUrl = url;

        selectedBloodType = bloodType;
        selectedRhFactor = rhFactor;

        // Флаги блокировки
        isNameLocked = nameController.text.isNotEmpty ||
            surnameController.text.isNotEmpty ||
            patronymicController.text.isNotEmpty;
        isOmsLocked = omsController.text.isNotEmpty;
        isDmsLocked = dmsController.text.isNotEmpty;
        isPassportLocked = passportSeriesController.text.isNotEmpty ||
            passportNumberController.text.isNotEmpty;
        isBloodGroupLocked =
            selectedBloodType != null && selectedRhFactor != null;

        isLoading = false;
      });
    } catch (e, st) {
      log('Error loading user data: $e\n$st');
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка загрузки данных')),
      );
    }
  }

  final List<Map<String, dynamic>> _bloodTypeRhMapping = [
    {'id': 1, 'type_blood': 'A(I)', 'neg_or_pos': 'Отрицательная'},
    {'id': 2, 'type_blood': 'A(I)', 'neg_or_pos': 'Положительная'},
    {'id': 3, 'type_blood': 'B(II)', 'neg_or_pos': 'Отрицательная'},
    {'id': 4, 'type_blood': 'B(II)', 'neg_or_pos': 'Положительная'},
    {'id': 5, 'type_blood': 'AB(III)', 'neg_or_pos': 'Положительная'},
    {'id': 6, 'type_blood': 'AB(III)', 'neg_or_pos': 'Отрицательная'},
    {'id': 7, 'type_blood': 'O(IV)', 'neg_or_pos': 'Положительная'},
    {'id': 8, 'type_blood': 'O(IV)', 'neg_or_pos': 'Отрицательная'},
  ];

  // Валидация
  String? _validateOms(String? value) {
    if (value == null || value.isEmpty) return 'Введите номер ОМС';
    if (!RegExp(r'^\d{16}$').hasMatch(value))
      return 'ОМС должен содержать 16 цифр';
    return null;
  }

  String? _validateDms(String? value) {
    if (value != null &&
        value.isNotEmpty &&
        !RegExp(r'^\d{6,16}$').hasMatch(value)) {
      return 'ДМС должен содержать от 6 до 16 цифр';
    }
    return null;
  }

  String? _validatePassportSeries(String? value) {
    if (value == null || value.isEmpty) return 'Введите серию паспорта';
    if (!RegExp(r'^\d{4}$').hasMatch(value))
      return 'Серия паспорта должна содержать 4 цифры';
    return null;
  }

  String? _validatePassportNumber(String? value) {
    if (value == null || value.isEmpty) return 'Введите номер паспорта';
    if (!RegExp(r'^\d{6}$').hasMatch(value))
      return 'Номер паспорта должен содержать 6 цифр';
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.isEmpty) return 'Введите адрес';
    return null;
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final nowUser = await getCurrentUser();
      final userId = nowUser['id'].toString();
      final storage = Supabase.instance.client.storage;
      final filePath = 'profiles/$userId.png';

      await storage.from('images').upload(filePath, File(pickedFile.path),
          fileOptions: FileOptions(upsert: true));
      final publicUrl = await storage.from('images').getPublicUrl(filePath);

      if (!mounted) return;
      setState(() {
        isChanged = true;
        localProfileFile1 = File(pickedFile.path);
        localProfileFile = File(pickedFile.path);
        profileImageUrl =
            '${publicUrl.toString()}?t=${DateTime.now().millisecondsSinceEpoch}';
      });
      log('Uploaded profile image URL: $publicUrl');
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    patronymicController.dispose();
    omsController.dispose();
    dmsController.dispose();
    passportSeriesController.dispose();
    passportNumberController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ваша учетная запись'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              Supabase.instance.client.auth.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const OnboardingPage()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 75,
                          backgroundColor: Colors.blue,
                          backgroundImage: localProfileFile != null
                              ? FileImage(localProfileFile!)
                              : (profileImageUrl != null
                                  ? NetworkImage(profileImageUrl!)
                                  : null) as ImageProvider<Object>?,
                          child: (localProfileFile == null &&
                                  profileImageUrl == null)
                              ? const Icon(Icons.person,
                                  size: 75, color: Colors.white54)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('🧑 Личные данные'),
                    _buildTextField(
                        controller: nameController,
                        label: 'Имя',
                        enabled: !isNameLocked),
                    _buildTextField(
                        controller: surnameController,
                        label: 'Фамилия',
                        enabled: !isNameLocked),
                    _buildTextField(
                        controller: patronymicController,
                        label: 'Отчество',
                        enabled: !isNameLocked),
                    _buildSectionTitle('📄 Паспорт'),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                              controller: passportSeriesController,
                              label: 'Серия',
                              keyboardType: TextInputType.number,
                              validator: _validatePassportSeries,
                              enabled: !isPassportLocked),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                              controller: passportNumberController,
                              label: 'Номер',
                              keyboardType: TextInputType.number,
                              validator: _validatePassportNumber,
                              enabled: !isPassportLocked),
                        ),
                      ],
                    ),
                    _buildSectionTitle('💳 Полисы'),
                    _buildTextField(
                        controller: omsController,
                        label: 'ОМС',
                        keyboardType: TextInputType.number,
                        validator: _validateOms,
                        enabled: !isOmsLocked),
                    _buildTextField(
                        controller: dmsController,
                        label: 'ДМС (если есть)',
                        keyboardType: TextInputType.number,
                        validator: _validateDms,
                        enabled: !isDmsLocked),
                    _buildSectionTitle('💉 Группа крови'),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedBloodType,
                            decoration: InputDecoration(
                              labelText: 'Группа',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            items: bloodTypes
                                .map((type) => DropdownMenuItem(
                                    value: type, child: Text(type)))
                                .toList(),
                            onChanged: isBloodGroupLocked
                                ? null
                                : (val) =>
                                    setState(() => selectedBloodType = val),
                            validator: (val) =>
                                val == null ? 'Выберите группу крови' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedRhFactor,
                            decoration: InputDecoration(
                              labelText: 'Резус',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            items: rhFactors
                                .map((factor) => DropdownMenuItem(
                                    value: factor, child: Text(factor)))
                                .toList(),
                            onChanged: isBloodGroupLocked
                                ? null
                                : (val) =>
                                    setState(() => selectedRhFactor = val),
                            validator: (val) =>
                                val == null ? 'Выберите резус-фактор' : null,
                          ),
                        ),
                      ],
                    ),
                    _buildSectionTitle('🏠 Адрес проживания'),
                    _buildTextField(
                        controller: addressController,
                        label: 'Адрес',
                        validator: _validateAddress),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Сохранить',
                          style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: enabled ? Colors.grey[100] : Colors.grey[300],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, исправьте ошибки в форме')),
      );
      return;
    }
    if (selectedBloodType == null || selectedRhFactor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Пожалуйста, выберите группу крови и резус')),
      );
      return;
    }

    try {
      final nowUser = await getCurrentUser();
      final userId = nowUser['id'].toString();  
      final selectedBloodId = _bloodTypeRhMapping.firstWhere((e) =>
          e['type_blood'] == selectedBloodType &&
          e['neg_or_pos'] == selectedRhFactor)['id'];

      await supabase.from('about_user').upsert({
        'id': userId,
        'oms': omsController.text,
        'dms': dmsController.text,
        'passport_series': passportSeriesController.text,
        'pasport_number': passportNumberController.text,
        'adress': addressController.text,
        'group_blood': selectedBloodId,
      });

      await supabase.from('user').update({
        'name': nameController.text,
        'surname': surnameController.text,
        'patronumic': patronymicController.text,
      }).eq('id', userId);

      if (!mounted) {
        setState(() {
          build(context);
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Данные успешно сохранены')),
      );
    } catch (e, st) {
      log('Error saving profile: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при сохранении данных')),
      );
    }
  }
}
