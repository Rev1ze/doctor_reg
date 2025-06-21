import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:priem_poliklinika/main.dart';
import 'package:priem_poliklinika/pages/main_pages/choose_menu.dart';
import 'package:priem_poliklinika/pages/auth_reg/registration.dart';
import 'package:priem_poliklinika/pages/main_pages/navbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginIn extends StatefulWidget {
  const LoginIn({super.key});

  @override
  State<LoginIn> createState() => _LoginInState();
}

class _LoginInState extends State<LoginIn> {
  late final TextEditingController loginController = TextEditingController();
  late final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Вход'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Form(
                child: TextFormField(
                  controller: loginController,
                  decoration: buildInputDecoration('Почта'),
                ),
              ),
              const SizedBox(height: 20),
              Form(
                child: TextFormField(
                  controller: passwordController,
                  decoration: buildInputDecoration('Пароль'),
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _auth(context);
                },
                style: const ButtonStyle(
                    maximumSize: WidgetStatePropertyAll(Size(250, 70))),
                child: const Text('Войти'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => RegPage()));
                    },
                    style: const ButtonStyle(
                        maximumSize: WidgetStatePropertyAll(Size(280, 50))),
                    child: const Text('Регистрация'),
                  ),
                  TextButton(
                    onPressed: () {
                      // Здесь можно добавить логику для обработки нажатия кнопки
                    },
                    child: const Text('Забыли пароль?'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => {},
                child: Image(
                  image: Image(image: AssetImage('assets/vk.png')).image,
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width * 0.1,
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _auth(BuildContext context) async {
    if (loginController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, заполните все поля.'),
        ),
      );
      return;
    }
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        password: passwordController.text,
        email: loginController.text,
      );
      if (response.user != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Вход выполнен успешно!'),
            ),
          );
        }
        log('Вход выполнен успешно: ${response.user?.email}');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => MainBottomNavBar()),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ошибка входа. Проверьте логин и пароль.'),
            ),
          );
        }
      }
    } on AuthException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка входа: Неверный логин или пароль.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Произошла ошибка: ${e.toString()}'),
          ),
        );
      }
    }
  }
}
