import 'dart:developer';

import 'package:age_calculator/age_calculator.dart';
import 'package:flutter/material.dart';
import 'package:priem_poliklinika/func/supabase_connect.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

InputDecoration buildInputDecoration(String labelText) {
  return InputDecoration(
    labelText: labelText,
    labelStyle: const TextStyle(color: Colors.black),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue, width: 2),
    ),
    border: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black),
    ),
  );
}

// ignore: must_be_immutable
class RegPage extends StatefulWidget {
  RegPage({super.key});
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController patronymicController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  @override
  State<RegPage> createState() => _RegPageState();
}

class _RegPageState extends State<RegPage> {
  String? selectedGender;
  String birthDateInString = '';
  DateTime birthDate = DateTime.now();
  bool isDateSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Регистрация'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: 350,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Form(
                child: TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: buildInputDecoration('Почта'),
                  controller: widget.emailController,
                ),
              ),
              const SizedBox(height: 20),
              Form(
                child: TextFormField(
                  keyboardType: TextInputType.phone,
                  decoration: buildInputDecoration('Телефон'),
                  controller: widget.phoneController,
                ),
              ),
              const SizedBox(height: 20),
              Form(
                child: TextFormField(
                  obscureText: true,
                  decoration: buildInputDecoration('Пароль'),
                  controller: widget.passwordController,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Ваша дата рождения'),
                  GestureDetector(
                      child: Icon(Icons.calendar_today),
                      onTap: () async {
                        final datePick = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100));
                        if (datePick != null && datePick != birthDate) {
                          setState(() {
                            birthDate = datePick;
                            isDateSelected = true;
                            // put it here
                            birthDateInString =
                                "${birthDate.year}-${birthDate.month}-${birthDate.day}"; // 08/14/2019
                          });
                        }
                      })
                ],
              ),
              const SizedBox(height: 20),
              Form(
                  child: TextFormField(
                decoration: buildInputDecoration('Фамилия'),
                controller: widget.surnameController,
              )),
              const SizedBox(height: 20),
              Form(
                  child: TextFormField(
                decoration: buildInputDecoration('Имя'),
                controller: widget.nameController,
              )),
              const SizedBox(height: 20),
              Form(
                  child: TextFormField(
                decoration: buildInputDecoration('Отчество'),
                controller: widget.patronymicController,
              )),
              const SizedBox(height: 20),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Пол'),
                      DropdownButton<String>(
                        value: selectedGender,
                        items: const [
                          DropdownMenuItem(
                              value: 'Мужской', child: Text('Мужской')),
                          DropdownMenuItem(
                              value: 'Женский', child: Text('Женский')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value;
                          });
                        },
                        hint: const Text('Выберите пол'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  int maxId = 0;
                  try {
                    final response = await Supabase.instance.client
                        .from('user')
                        .select()
                        .order('id', ascending: false)
                        .limit(1)
                        .single();
                    final maxUser = response; // это Map с данными пользователя
                    maxId = maxUser['id']; // получаем максимальный ID
                  } catch (e) {
                    log('Ошибка при получении максимального ID: $e');
                    maxId = 0; // если произошла ошибка, устанавливаем maxId в 0
                  }

                  log('Пользователь с максимальным ID: $maxId');

                  final email = widget.emailController.text;
                  final password = widget.passwordController.text;
                  final surname = widget.surnameController.text;
                  final name = widget.nameController.text;
                  final patronymic = widget.patronymicController.text;
                  final gender = selectedGender;
                  final phone = widget.phoneController.text;
                  String gender1 = "";
                  if (email.isEmpty ||
                      password.isEmpty ||
                      surname.isEmpty ||
                      name.isEmpty ||
                      patronymic.isEmpty ||
                      phone.isEmpty ||
                      gender == null ||
                      isDateSelected == false) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Пожалуйста, заполните все поля')),
                    );
                    return;
                  }
                  if (gender == 'Мужской') {
                    gender1 = 'MALE';
                  } else {
                    gender1 = 'FEMALE';
                  }
                  if (birthDate.year < 1900 ||
                      birthDate.year > DateTime.now().year) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Пожалуйста, выберите корректную дату')),
                    );
                    return;
                  } else if (AgeCalculator.age(birthDate).years < 18) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Вы должны быть старше 18 лет')),
                    );
                    return;
                  }
                  try {
                    final user = await supabase.auth.signUp(
                      email: email,
                      password: password,
                      data: {
                        'surname': surname,
                        'name': name,
                        'patronymic': patronymic,
                        'gender': gender1,
                        'phone_number': phone,
                        'birthday': birthDateInString,
                      },
                    );
                    log(user.user!.id.toString());
                    final response =
                        await Supabase.instance.client.from('user').insert({
                      'id': maxId + 1,
                      'email': email,
                      'password': password,
                      'surname': surname,
                      'name': name,
                      'patronumic': patronymic,
                      "gender": gender1,
                      'uuid': user.user!.id,
                      'phone_number': phone,
                      'created_at': DateTime.now().toIso8601String(),
                      'birthday': birthDateInString
                    });
                    if (response.error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Ошибка регистрации: ${response.error!.message}'),
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ошибка: $e')),
                    );
                    return;
                  }
                },
                style: const ButtonStyle(
                    maximumSize: WidgetStatePropertyAll(Size(250, 70))),
                child: const Text('Зарегистрироваться'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
