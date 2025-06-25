import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:priem_poliklinika/func/func.dart';
import 'package:priem_poliklinika/pages/auth_reg/registration.dart';
import 'package:priem_poliklinika/pages/main_pages/doctor_main_page.dart';
import 'package:priem_poliklinika/pages/main_pages/navbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

dynamic user;

class UnifiedLoginPage extends StatefulWidget {
  const UnifiedLoginPage({super.key});

  @override
  State<UnifiedLoginPage> createState() => _UnifiedLoginPageState();
}

class _UnifiedLoginPageState extends State<UnifiedLoginPage> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isDoctor = false;
  bool _isLoading = false;
  String? _errorMessage;

  final supabase = Supabase.instance.client;

  InputDecoration buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      prefixIcon:
          label == 'Пароль' ? const Icon(Icons.lock) : const Icon(Icons.person),
    );
  }

  Future<void> _auth() async {
    final login = _loginController.text.trim();
    final password = _passwordController.text;

    if (login.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, заполните все поля.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isDoctor) {
        final debugList = await Supabase.instance.client
            .from('doctors_profile')
            .select('login');

        log('Все логины: ${debugList.map((e) => e['login']).toList()}');
        log(login);
        final response = await Supabase.instance.client
            .from('doctors_profile')
            .select('*')
            .eq('login', login)
            .limit(1)
            .maybeSingle();

        if (response == null) {
          setState(() {
            _errorMessage = 'Доктор с таким логином не найден';
            _isLoading = false;
          });
          return;
        }

        if (response['password'] != password) {
          setState(() {
            _errorMessage = 'Неверный пароль';
            _isLoading = false;
          });
          return;
        }

        final doctorId = response['doctor_id'];

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Вход как доктор выполнен успешно!')),
        );

        // Переход в главное окно доктора (создай экран по своему усмотрению)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (_) =>
                  DoctorAppointmentsPage(doctorId: doctorId)), // Заглушка
        );
      } else {
        // Авторизация пациента через Supabase auth
        final response = await supabase.auth.signInWithPassword(
          email: login,
          password: password,
        );

        if (response.user != null) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Вход выполнен успешно!')),
          );
          user = await getCurrentUser();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MainBottomNavBar()),
          );
        } else {
          setState(() {
            _errorMessage = 'Ошибка входа. Проверьте логин и пароль.';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Произошла ошибка: ${e.toString()}';
        log(_errorMessage.toString());
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Вход'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ToggleButtons(
                isSelected: [_isDoctor == false, _isDoctor == true],
                onPressed: (index) {
                  setState(() {
                    _isDoctor = index == 1;
                    _errorMessage = null;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                selectedColor: Colors.white,
                fillColor: Colors.blue,
                color: Colors.blue,
                constraints:
                    BoxConstraints(minWidth: 120, minHeight: 40), // размеры
                children: const [
                  Text('Пациент'),
                  Text('Доктор'),
                ],
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _loginController,
                decoration: buildInputDecoration(_isDoctor ? 'Логин' : 'Почта'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: buildInputDecoration('Пароль'),
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _auth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    textStyle: TextStyle(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Войти',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              if (!_isDoctor)
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => RegPage()));
                    },
                    style: const ButtonStyle(
                        maximumSize: MaterialStatePropertyAll(Size(280, 50))),
                    child: const Text('Регистрация'),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
