import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerSection extends StatelessWidget {
  final DateTime pickupDate;
  final VoidCallback onTap;

  const DatePickerSection({
    super.key,
    required this.pickupDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_today, color: Color(0xff0096C9)),
        title: const Text("Tanggal Jemput"),
        subtitle: Text(DateFormat('EEEE, dd MMMM yyyy').format(pickupDate)),
        onTap: onTap,
      ),
    );
  }
}