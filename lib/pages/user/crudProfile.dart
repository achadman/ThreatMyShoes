// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter03/pages/profilePage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Crudprofile extends StatefulWidget {
  const Crudprofile({super.key});

  @override
  State<Crudprofile> createState() => _CrudprofileState();
}

class _CrudprofileState extends State<Crudprofile> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getInitialProfile();
  }

  File? _avatarUrl;
  String? _currentAvatarUrl;

  //pilih gambar
  Future pickImage() async {
    //picker
    final ImagePicker picker = ImagePicker();

    //ambil dari galeri
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    //update preview
    if (image != null) {
      setState(() {
        _avatarUrl = File(image.path);
      });
    }
  }

  //upload
  Future<String?> uploadImage() async {
    if (_avatarUrl == null) return null;

    // buat file path url uniqe
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final path = 'uploads/$fileName';

    //upload gambar
    await Supabase.instance.client.storage
        .from('avatars')
        .upload(path, _avatarUrl!);

    final imageUrl = Supabase.instance.client.storage
        .from('avatars')
        .getPublicUrl(path);
    return imageUrl;
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);

    try {
      final userId = supabase.auth.currentUser!.id;

      final imageUrl = await uploadImage();

      final updates = {
        'id': userId,
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (imageUrl != null) {
        updates['avatar_url'] = imageUrl;
      }

      await supabase.from('profiles').upsert(updates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil berhasil diperbarui!")),
        );
        Navigator.pop(context);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal menyimpan: $error"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _getInitialProfile() async {
    setState(() => _isLoading = true);
    try {
      final userId = supabase.auth.currentUser!.id;

      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      _nameController.text = data['name'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      _addressController.text = data['address'] ?? '';
      _currentAvatarUrl = data['avatar_url'];
    } catch (error) {
      print("Info: Profil belum dibuat atau error: $error");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profil"),
        actions: [
          IconButton(
            onPressed: _updateProfile,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // --- Bagian Foto Profil ---
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        maxRadius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _avatarUrl != null
                            ? FileImage(_avatarUrl!)
                            : (_currentAvatarUrl != null &&
                                  _currentAvatarUrl!.isNotEmpty)
                            ? NetworkImage(_currentAvatarUrl!)
                            : const AssetImage('assets/logo/logo02.png')
                                  as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 18,
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              pickImage();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- Form Input ---
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Nama Lengkap",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Nomor HP",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _addressController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Alamat",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
              ],
            ),
    );
  }
}
