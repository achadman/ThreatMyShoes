class Treatment {
  final int? id; // Tambahkan ID dari database
  final String name;
  final int price;
  final int baseDays;

  Treatment({
    this.id,
    required this.name,
    required this.price,
    required this.baseDays,
  });

  // Fungsi untuk mengubah JSON dari Supabase menjadi Objek Treatment
  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      baseDays: json['base_days'], // sesuaikan dengan nama kolom di SQL (base_days)
    );
  }
}