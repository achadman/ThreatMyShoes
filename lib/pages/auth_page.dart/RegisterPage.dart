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
  // Tambahkan variabel ini di dalam _RegisterPageState
  bool _isLoading = false;
  // Tambahkan di bagian atas kelas state
  bool _isObscured = true;
  bool _isConfirmObscured = true;
  void signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // 1. Validasi Input
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar("Semua kolom wajib diisi!", isError: true);
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar("Password dan konfirmasi tidak cocok.", isError: true);
      return;
    }

    if (password.length < 6) {
      _showSnackBar("Password minimal harus 6 karakter.", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Proses Pendaftaran
      await authService.signUpWithEmailPassword(email, password);

      if (mounted) {
        _showSnackBar("Pendaftaran berhasil! Silakan login.");
        Navigator.pop(context);
      }
    } catch (e) {
      // 3. Terjemahkan Error
      String errorMessage = "Gagal mendaftar. Silakan coba lagi.";
      String errorStr = e.toString().toLowerCase();

      if (errorStr.contains("user already exists")) {
        errorMessage = "Email ini sudah terdaftar. Gunakan email lain.";
      } else if (errorStr.contains("network") || errorStr.contains("socket")) {
        errorMessage = "Koneksi internet bermasalah.";
      } else if (errorStr.contains("invalid-email")) {
        errorMessage = "Format email tidak valid.";
      }

      if (mounted) {
        _showSnackBar(errorMessage, isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Fungsi Helper SnackBar yang rapi
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryPurple = Color(0xFF24465F);
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
                  "assets/logo/treatmyshoes.png",
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
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF778873),
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  ),
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
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmObscured
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: const Color(0xFF778873),
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmObscured = !_isConfirmObscured;
                      });
                    },
                  ),
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
              // Ganti ElevatedButton lama dengan ini:
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : signUp, // Disable tombol saat loading
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPurple,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Sign Up',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
