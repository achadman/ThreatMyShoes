import 'package:flutter/material.dart';

class Berandapage extends StatefulWidget {
  const Berandapage({super.key});
  @override
  State<Berandapage> createState() => _BerandaState();
}

class _BerandaState extends State<Berandapage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
          Text('Ini Halmaan Beranda'),
          ]
        ),
      ),
    );
  }
}
