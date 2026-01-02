// ignore_for_file: file_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter03/Auth/auth_services.dart';
import 'package:flutter03/pages/auth_page.dart/loginPage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //get auth service
  final authService = AuthServices();

  //text Controller
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  //Ketika menekan tombol sign up
  void signUp() async {
    // Siapkan data
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // 1. Pengecekan KEKOSONGAN (Disarankan di awal)
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Konten Tidak Boleh Kosong")),
      );
      return;
    }

    // 2. Pengecekan Kecocokan Password
    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Password Tidak Sama ")));
      return;
    }

    // 3. Mencoba untuk mendaftar
    try {
      await authService.signUpWithEmailPassword(email, password);

      // 4. Tutup halaman ketika selesai
      Navigator.pop(context);
    } catch (e) {
      // 5. Penanganan Error Saat Sign Up
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryPurple = Color(0xFF4A7F91);
    const Color primaryPurple2 = Color(0xFF778873);
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -150,
            left: -150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
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
                  "assets/logo/logoTreatMyshoes.png",
                  width: 100,
                  height: 100,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              //Teks
              const Text(
                'Sign Up',
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
                    "Sudah punya akun? ",
                    style: TextStyle(color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LoginPage()),
                      );
                    },
                    child: const Text(
                      'Masuk',
                      style: TextStyle(
                        color: primaryPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Input Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: primaryPurple2),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primaryPurple, width: 2),
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

              SizedBox(height: 8),

              // Input password
              TextField(
                controller: _passwordController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: primaryPurple2),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primaryPurple, width: 2),
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

              SizedBox(height: 8),
              // Password
              TextField(
                controller: _confirmPasswordController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password',
                  labelStyle: TextStyle(color: primaryPurple2),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primaryPurple, width: 2),
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

              SizedBox(height: 12),

              // Tombol Sign Up
              ElevatedButton.icon(
                onPressed: () {
                  signUp();
                },
                label: const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPurple,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
