import 'package:flutter/material.dart';
import 'package:flutter03/Auth/auth_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  //supabase setup
  await Supabase.initialize(
    url: "https://buflzpusvcwtrkorpwen.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ1Zmx6cHVzdmN3dHJrb3Jwd2VuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUyNzY1NzgsImV4cCI6MjA4MDg1MjU3OH0.D9SjUjysOMKka_6dFiKyr3G-t7LeXxMXepCKeLJ2qEI",
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: const AuthGate(),
    );
  }
}
