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
  // Get auth service
  final authService = AuthServices();

  // Text Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State Variables
  bool _isLoading = false;
  bool _isObscured = true;
  bool _isConfirmObscured = true;

  void signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // 1. Validasi Input Dasar
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar("Semua kolom wajib diisi!", isError: true);
      return;
    }

    // 2. Validasi Format Email (Regex)
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _showSnackBar("Format email tidak valid!", isError: true);
      return;
    }

    // 3. Validasi Password
    if (password.length < 6) {
      _showSnackBar("Password minimal harus 6 karakter.", isError: true);
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar("Password dan konfirmasi tidak cocok.", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 4. Proses Pendaftaran ke Service
      await authService.signUpWithEmailPassword(email, password);

      if (mounted) {
        _showSnackBar("Pendaftaran berhasil! Silakan login.");
        Navigator.pop(context);
      }
    } catch (e) {
      // PENTING: Print error ke console untuk debugging (F12 di browser)
      debugPrint("DEBUG_AUTH_ERROR: $e");

      // 5. Terjemahkan Error Berdasarkan Pesan dari Backend/Firebase
      String errorMessage = "Gagal mendaftar. Silakan coba lagi.";
      String errorStr = e.toString().toLowerCase();

      if (errorStr.contains("already-in-use") ||
          errorStr.contains("user already exists")) {
        errorMessage = "Email ini sudah terdaftar. Gunakan email lain.";
      } else if (errorStr.contains("network") || errorStr.contains("socket")) {
        errorMessage = "Koneksi internet bermasalah atau CORS error.";
      } else if (errorStr.contains("invalid-email")) {
        errorMessage = "Format email tidak valid.";
      } else if (errorStr.contains("weak-password")) {
        errorMessage = "Password terlalu lemah.";
      }

      if (mounted) {
        _showSnackBar(errorMessage, isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Fungsi Helper SnackBar
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    // Selalu dispose controller untuk menghindari memory leak
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Colors.blue;
    const Color primaryGrey = Color(0xFF778873);

    return Scaffold(
      body: Stack(
        children: [
          // Background Dekorasi
          Positioned(
            top: -150,
            left: -150,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                color: primaryBlue,
                shape: BoxShape.circle,
              ),
            ),
          ),

          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.10),
              Center(
                child: Image.asset(
                  "assets/logo/treatmyshoes.png",
                  width: 100,
                  height: 100,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image, size: 100),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              const Text(
                'Buat Akun',
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
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    ),
                    child: const Text(
                      'Masuk',
                      style: TextStyle(
                        color: primaryBlue,
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
                decoration: _buildInputDecoration(
                  "Email",
                  Icons.email_outlined,
                  primaryBlue,
                  primaryGrey,
                ),
              ),

              const SizedBox(height: 15),

              // Input Password
              TextField(
                controller: _passwordController,
                obscureText: _isObscured, // Memperbaiki bug sebelumnya
                decoration: _buildInputDecoration(
                  "Password",
                  Icons.lock_outline,
                  primaryBlue,
                  primaryGrey,
                  isPassword: true,
                  isObscured: _isObscured,
                  onToggle: () => setState(() => _isObscured = !_isObscured),
                ),
              ),

              const SizedBox(height: 15),

              // Input Konfirmasi Password
              TextField(
                controller: _confirmPasswordController,
                obscureText: _isConfirmObscured, // Memperbaiki bug sebelumnya
                decoration: _buildInputDecoration(
                  "Konfirmasi Password",
                  Icons.lock_clock_outlined,
                  primaryBlue,
                  primaryGrey,
                  isPassword: true,
                  isObscured: _isConfirmObscured,
                  onToggle: () =>
                      setState(() => _isConfirmObscured = !_isConfirmObscured),
                ),
              ),

              const SizedBox(height: 30),

              // Tombol Sign Up
              ElevatedButton(
                onPressed: _isLoading ? null : signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
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
                        'Buat Akun',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper Dekorasi Input agar kode lebih bersih
  InputDecoration _buildInputDecoration(
    String label,
    IconData icon,
    Color primary,
    Color grey, {
    bool isPassword = false,
    bool? isObscured,
    VoidCallback? onToggle,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: grey),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                isObscured! ? Icons.visibility_off : Icons.visibility,
                color: grey,
              ),
              onPressed: onToggle,
            )
          : null,
      labelStyle: TextStyle(color: grey),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: primary, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: grey.withOpacity(0.5), width: 1),
      ),
    );
  }
}
