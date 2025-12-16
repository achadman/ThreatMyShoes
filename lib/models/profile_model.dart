// ignore_for_file: file_names

class UserProfile {
  final String uid;

  String name;
  String phone;
  String address;
  String avatarUrl;

  UserProfile({
    required this.uid,
    required this.name,
    this.phone = '',
    this.address = 'Alamat belum diatur',
    this.avatarUrl = '',
  });

  // Konstruktor dari JSON (Mengambil data dari Supabase)
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['id'] ?? '',
      name: json['name'] ?? 'Nama UMKM Baru',
      phone: json['phone'] ?? '',
      address: json['address'] ?? 'Alamat belum diatur',
      avatarUrl: json['avatar_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': uid,
      'name': name,
      'phone': phone,
      'address': address,
      'avatar_url': avatarUrl,
    };
  }
}
