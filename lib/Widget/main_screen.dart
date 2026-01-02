import 'package:flutter/material.dart';
import 'package:flutter03/pages/chatPage.dart';
import 'package:flutter03/pages/homepage.dart';
import 'package:flutter03/pages/menuPage.dart';
import 'package:flutter03/pages/profilePage.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Center(child: Berandapage()),
    const Center(child: Menupage()),
    const Center(child: Chatpage()),
    const Center(child: ProfilePage()),
  ];
  final List<String> _titles = [
    "Beranda",
    "Menu",
    "Chat",
    "Profil ",
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF4A7F91);
    return Scaffold(
      appBar: AppBar(
      backgroundColor: const Color(0xFF4A7F91),
      centerTitle: true,
      // Judul akan berubah otomatis saat _currentIndex berubah
      title: Text(
        _titles[_selectedIndex], 
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Image.asset("assets/logo/logo03.png", fit: BoxFit.fitWidth,),

      ),
      leadingWidth: 50,
    ),
    
      body: _pages[_selectedIndex],

      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, -5), // Shadow ke arah atas
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          selectedItemColor: primary,
          unselectedItemColor: Colors.grey.shade400,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,

          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.grid_view_rounded),
              ),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.shopping_bag_outlined),
              ),
              label: 'Menu',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.chat_bubble_outline_rounded),
              ),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.person_2_outlined),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
