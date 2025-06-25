import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:priem_poliklinika/func/func.dart';
import 'package:priem_poliklinika/main.dart';
import 'package:priem_poliklinika/pages/auth_reg/login.dart';
import 'package:priem_poliklinika/pages/main_pages/appointments.dart';
import 'package:priem_poliklinika/pages/main_pages/clinic_choose.dart';
import 'package:priem_poliklinika/pages/main_pages/doctor_choose.dart';
import 'package:priem_poliklinika/pages/main_pages/navbar.dart';
import 'package:priem_poliklinika/pages/main_pages/profile.dart';
import 'package:priem_poliklinika/pages/widgets/main_menu_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

var ultraUser;
dynamic _isLoading = true;

class MainMenu extends StatefulWidget {
  const MainMenu({
    super.key,
  });

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  Future<void> getUser() async {
    log('грузится');
    ultraUser = await getCurrentUser();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading == true) {
      return const Center(child: CircularProgressIndicator());
    }

    if (ultraUser == null) {
      return const Center(
        child: Text('Ошибка, не прогрузился профиль'),
      );
    }
    if (user == null) {
      return const Center(
        child: Text('Ошибка, не прогрузился профиль'),
      );
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Главное меню'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MenuCard(
                    iconPath: 'assets/priem.svg',
                    label: 'Записаться на прием\nк врачу',
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ClinicChoose(
                                userId: Supabase.instance.client.auth
                                    .currentSession!.user.id,
                                is_choose: true,
                              )));
                    },
                  ),
                  MenuCard(
                    iconPath: 'assets/doctor.svg',
                    label: 'Просмотреть всех врачей',
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => DoctorChoose(
                                userId: Supabase.instance.client.auth
                                    .currentSession!.user.id,
                                isChoose: true,
                                clinicId: -1,
                              )));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MenuCard(
                    iconPath: 'assets/hospital.svg',
                    label: 'Медицинские организации',
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ClinicChoose(
                                is_choose: false,
                                userId: ultraUser['id'].toString(),
                              )));
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MenuCard(
                        iconPath: 'assets/timetable.svg',
                        label: 'Мои записи',
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => MyAppointmentsPage()));

                          MyAppointmentsPage();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
