import 'package:flutter/material.dart';
import 'package:flutter03/pages/status_page.dart';
import 'package:flutter03/pages/homepage.dart';
import 'package:flutter03/pages/menuPage.dart';
import 'package:flutter03/pages/profilePage.dart';
import 'package:flutter03/pages/Pesanan/history_pages.dart'; // Pastikan import riwayat ada

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String? _selectedCategory;

  final List<String> _titles = ["Beranda", "Menu", "Riwayat", "Profil"];

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Reset kategori jika pindah tab agar saat balik ke beranda tidak langsung ke Menu
      if (index != 0) _selectedCategory = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Logika Penentuan Body secara Dinamis
    Widget currentBody;

    switch (_selectedIndex) {
      case 0: // Tab Beranda
        if (_selectedCategory == 'Sepatu') {
          currentBody = MenuPage(
            onBack: () {
              setState(() => _selectedCategory = null);
            },
          );
        } else {
          currentBody = HomePage(onSelect: _onCategorySelected);
        }
        break;
      case 1:
        currentBody = const HistoryPages();
        break;
      case 2:
        currentBody = const StatusPage(orderId: '', status: '');
        break;
      case 3:
        currentBody = const ProfilePage();
        break;
      default:
        currentBody = HomePage(onSelect: _onCategorySelected);
    }

    const Color primary = Color(0xFF18ADFF);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        centerTitle: true,
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Image.asset("assets/logo/logo-1.png", fit: BoxFit.fitWidth),
        ),
        leadingWidth: 50,
      ),

      // 2. Gunakan currentBody hasil logika di atas, bukan _pages[_selectedIndex]
      body: currentBody,

      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, -5),
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
              icon: Icon(Icons.grid_view_outlined),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.note_outlined,
              ), // Ikon diganti ke Riwayat agar cocok
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.delivery_dining_outlined),
              label: 'Status',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
