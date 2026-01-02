// ignore_for_file: file_names, avoid_print

import 'package:flutter/material.dart';
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

  void signOut() async {
    try {
      await supabase.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saat logout: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF4A7F91);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. HEADER HIJAU (Tanpa Stack yang rumit)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 30),
            decoration: const BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              children: [
                // FOTO PROFIL
                CircleAvatar(
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
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                // NAMA
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _userName ?? "Nama Pengguna",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(width: 12,),
                    Text(
                      _phoneNumber ?? "62+",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),

                // TELP
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. DAFTAR MENU (Menggunakan ListTile Standar)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text("Edit Profil"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Crudprofile(),
                      ),
                    ).then((value) => _getProfileData());
                  },
                ),
                const Divider(), // Garis pemisah
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text("Riwayat Pesanan"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    "Log Out",
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: signOut,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
