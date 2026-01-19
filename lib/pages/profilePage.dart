// ignore_for_file: file_names, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter03/pages/Pesanan/history_pages.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter03/pages/auth_page.dart/loginPage.dart';
import 'package:flutter03/pages/user/crudProfile.dart';

final supabase = Supabase.instance.client;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _userName;
  String? _phoneNumber;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _getProfileData();
  }

  Future<void> _getProfileData() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      setState(() {
        _userName = data['name'];
        _phoneNumber = data['phone'];
        _avatarUrl = data['avatar_url'];
      });
    } catch (e) {
      print("Error fetching profile data: $e");
    }
  }

  // LOGOUT DENGAN KONFIRMASI
  void signOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Log Out"),
        content: const Text("Apakah Anda yakin ingin keluar dari akun?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              try {
                await supabase.auth.signOut();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Terjadi kesalahan: $e')),
                  );
                }
              }
            },
            child: const Text("Keluar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF18ADFF);
    const Color secondary = Color(0xFF0077B5);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // HEADER PROFIL
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 70, bottom: 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primary, secondary],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 47,
                      backgroundColor: Colors.grey[200],
                      backgroundImage:
                          (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                          ? NetworkImage(_avatarUrl!)
                          : null,
                      child: (_avatarUrl == null || _avatarUrl!.isEmpty)
                          ? const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  _userName ?? "Nama Pengguna",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _phoneNumber ?? "+62",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // MENU
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildMenuTile(
                  title: "Edit Profil",
                  subtitle: "Perbarui informasi pribadi Anda",
                  icon: Icons.person_outline_rounded,
                  iconColor: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Crudprofile(),
                      ),
                    ).then((_) => _getProfileData());
                  },
                ),
                _buildMenuTile(
                  title: "Riwayat Pesanan",
                  subtitle: "Cek status cucian sepatu Anda",
                  icon: Icons.history_rounded,
                  iconColor: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HistoryPages(),
                      ),
                    );
                  },
                ),
                _buildMenuTile(
                  title: "Pusat Bantuan",
                  subtitle: "Hubungi kami jika ada kendala",
                  icon: Icons.help_outline_rounded,
                  iconColor: Colors.green,
                  onTap: () {},
                ),
                const SizedBox(height: 20),
                const Divider(thickness: 1, indent: 10, endIndent: 10),
                const SizedBox(height: 10),
                _buildMenuTile(
                  title: "Log Out",
                  subtitle: "Keluar dari sesi aplikasi",
                  icon: Icons.logout_rounded,
                  iconColor: Colors.red,
                  isDestructive: true,
                  onTap: signOut,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET MENU
  Widget _buildMenuTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDestructive ? Colors.red : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
        onTap: onTap,
      ),
    );
  }
}
