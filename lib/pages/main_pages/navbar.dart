import 'package:flutter/material.dart';
import 'package:priem_poliklinika/main.dart';
import 'package:priem_poliklinika/pages/auth_reg/login.dart';
import 'package:priem_poliklinika/pages/main_pages/choose_menu.dart';
import 'package:priem_poliklinika/pages/main_pages/profile.dart';

bool isChanged = false;
dynamic localProfileFile;

class MainBottomNavBar extends StatefulWidget {
  const MainBottomNavBar({super.key});

  @override
  State<MainBottomNavBar> createState() => _MainBottomNavBarState();
}

class _MainBottomNavBarState extends State<MainBottomNavBar> {
  int _selectedIndex = 0;

  Widget _buildProfileAvatar() {
    if (!isChanged) {
      return FutureBuilder(
        future: get_profile_page_path(),
        builder: (context, snapshot) {
          if (localProfileFile != null) {
            return CircleAvatar(
                radius: 20,
                backgroundImage: FileImage(
                  localProfileFile,
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
        backgroundImage: FileImage(localProfileFile),
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
      body: [
        MainMenu(),
        Center(
          child: Text('data'),
        ),
        ProfilePage()
      ][_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Другое',
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
