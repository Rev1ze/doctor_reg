import 'package:flutter/material.dart';
import 'package:priem_poliklinika/main.dart';
import 'package:priem_poliklinika/pages/auth_reg/login.dart';
import 'package:priem_poliklinika/pages/main_pages/choose_menu.dart';
import 'package:priem_poliklinika/pages/main_pages/profile.dart';

bool isChanged = false;
dynamic localProfileFile1;

class MainBottomNavBar extends StatefulWidget {
  const MainBottomNavBar({super.key});

  @override
  State<MainBottomNavBar> createState() => _MainBottomNavBarState();
}

class _MainBottomNavBarState extends State<MainBottomNavBar> {
  int _selectedIndex = 0;

  Widget  _buildProfileAvatar() {
    if (!isChanged) {
      return FutureBuilder(
        future: get_profile_page_path(),
        builder: (context, snapshot) {
          if (localProfileFile1 != null) {
            return CircleAvatar(
                radius: 20,
                backgroundImage: FileImage(
                  localProfileFile1,
                ));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircleAvatar(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data != null) {
            return CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(snapshot.data!),
            );
          } else {
            return const CircleAvatar(
              radius: 20,
              child: Icon(Icons.person),
            );
          }
        },
      );
    } else {
      return CircleAvatar(
        radius: 20,
        backgroundImage: FileImage(localProfileFile1),
      );
    }
  }

  void _onItemTapped(int index) async {
    if (!mounted) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [MainMenu(), ProfilePage()][_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: _buildProfileAvatar(),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
