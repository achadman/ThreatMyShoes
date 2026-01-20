// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Tambahkan untuk ikon cupertino
import 'package:flutter03/Auth/auth_services.dart';
import 'package:flutter03/pages/auth_page.dart/RegisterPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final authService = AuthServices();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isObscure = true; // Untuk fitur show/hide password

  void login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showFriendlyError("Email dan password tidak boleh kosong, ya!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await authService.signInWithEmailPassword(email, password);
      final user = Supabase.instance.client.auth.currentUser;

      if (user != null && mounted) {
        final userData = await Supabase.instance.client
            .from('profiles')
            .select('role')
            .eq('id', user.id)
            .maybeSingle();

        String role = userData?['role'] ?? 'user';

        if (role == 'owner') {
          Navigator.pushReplacementNamed(context, '/admin_dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      String errorMessage = "Terjadi kesalahan yang tidak diketahui.";
      String errorString = e.toString().toLowerCase();

      if (errorString.contains("invalid login credentials")) {
        errorMessage = "Email atau password salah. Silakan cek kembali.";
      } else if (errorString.contains("network") ||
          errorString.contains("socketexception")) {
        errorMessage =
            "Koneksi internet bermasalah. Pastikan internetmu aktif.";
      } else if (errorString.contains("too many requests")) {
        errorMessage = "Terlalu banyak percobaan login. Tunggu sebentar lagi.";
      }

      if (mounted) {
        _showFriendlyError(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showFriendlyError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryPurple = Colors.blue;
    const Color primaryPurple2 = Color(0xFF778873);

    return Scaffold(
      // Bungkus seluruh body dengan Stack
      body: Stack(
        children: [
          // LAYER 1: UI UTAMA
          Positioned(
            top: -150,
            left: -150,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                color: primaryPurple,
                shape: BoxShape.circle,
              ),
            ),
          ),
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.10),
              SizedBox(
                child: Image.asset(
                  "assets/logo/treatmyshoes.png",
                  width: 100,
                  height: 100,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              const Text(
                'Masuk Akun',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    "Tidak memiliki akun? ",
                    style: TextStyle(color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      );
                    },
                    child: const Text(
                      'Buat akun',
                      style: TextStyle(
                        color: primaryPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: primaryPurple2),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: primaryPurple,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: primaryPurple2,
                      width: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: _isObscure, // Menggunakan variabel boolean
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: primaryPurple2),
                  // FITUR MATA (SHOW/HIDE)
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure
                          ? CupertinoIcons.eye_slash
                          : CupertinoIcons.eye,
                      color: primaryPurple2,
                    ),
                    onPressed: () => setState(() => _isObscure = !_isObscure),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: primaryPurple,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: primaryPurple2,
                      width: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : login, // Matikan tombol saat loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPurple,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Masuk',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

          // LAYER 2: OVERLAY LOADING (Hanya muncul jika _isLoading = true)
          if (_isLoading)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.5), // Efek Gelap
              child: Center(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF18ADFF)),
                        SizedBox(height: 15),
                        Text(
                          "Tunggu sebentar...",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
