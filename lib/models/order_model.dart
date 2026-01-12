import 'package:flutter/material.dart';

class OrderModel {
  final String id;
  final String service;
  final String status;

  OrderModel({
    required this.id,
    required this.service,
    required this.status,
  });
}
final List<Map<String, dynamic>> statusSteps = [
  {
    "title": "Pesanan Dibuat",
    "icon": Icons.receipt_long,
    "date": "10 Jan 2026 • 09:20"
  },
  {
    "title": "Dijemput Kurir",
    "icon": Icons.motorcycle,
    "date": "10 Jan 2026 • 10:00"
  },
  {
    "title": "Diterima Outlet",
    "icon": Icons.store,
    "date": "10 Jan 2026 • 11:30"
  },
  {
    "title": "Sedang Diproses",
    "icon": Icons.local_laundry_service,
    "date": "10 Jan 2026 • 13:00"
  },
  {
    "title": "Sedang Diantar",
    "icon": Icons.local_shipping,
    "date": "-"
  },
];
