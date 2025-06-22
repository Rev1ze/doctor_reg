import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:priem_poliklinika/main.dart';
import 'package:priem_poliklinika/pages/main_pages/clinic_choose.dart';
import 'package:priem_poliklinika/pages/main_pages/doctor_choose.dart';
import 'package:priem_poliklinika/pages/main_pages/navbar.dart';
import 'package:priem_poliklinika/pages/main_pages/profile.dart';
import 'package:priem_poliklinika/pages/widgets/main_menu_widget.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({
    super.key,
  });

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  @override
  Widget build(BuildContext context) {
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
                          builder: (context) => DoctorChoose(is_choose: true)));
                    },
                  ),
                  MenuCard(
                    iconPath: 'assets/doctor.svg',
                    label: 'Просмотреть всех врачей',
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              DoctorChoose(is_choose: false)));
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
                          builder: (context) => ClinicChoose()));
                    },
                  ),
                  MenuCard(
                    iconPath: 'assets/anketa.svg',
                    label: 'Анкеты',
                    onTap: () {
                      // TODO: Add navigation or action
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MenuCard(
                    iconPath: 'assets/timetable.svg',
                    label: 'Расписание врачей',
                    onTap: () {
                      // TODO: Add navigation or action
                    },
                  ),
                  MenuCard(
                    iconPath: 'assets/med_card.svg',
                    label: 'Медицинская карта',
                    onTap: () {
                      // TODO: Add navigation or action
                    },
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
