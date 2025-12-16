// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter03/Auth/auth_services.dart';
import 'package:flutter03/pages/auth_page.dart/RegisterPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final authService = AuthServices();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  //login
  void login() async {
    // Siapkan  data
    final email = _emailController.text;
    final password = _passwordController.text;
    //1.  Cek Input Kekosongan
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Konten Tidak Boleh Kosong")),
      );
      return;
    }
    //2. Coba untuk login
    try {
      await authService.signInWithEmailPassword(email, password);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("ERROR '$e'")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryPurple = Color(0xFF004030);
    const Color primaryPurple2 = Color(0xFF778873);

    return Scaffold(
      body: Stack(
        children: [
          //Lingkaran kiri atas
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.25),

              // 1. Login Teks
              const Text(
                'Login',
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
                    "Tidak memiliki akun ? ",
                    style: TextStyle(color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RegisterPage()),
                      );
                    },
                    child: const Text(
                      'sign up',
                      style: TextStyle(
                        color: primaryPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // 2. Input Email
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
              //3. Input password
              TextField(
                controller: _passwordController,
                obscureText: true,

                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: primaryPurple2),
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

              // 4. Tombol Login
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    login();
                  },
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  label: const Text(
                    'Login',
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}
