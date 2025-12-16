import 'package:supabase_flutter/supabase_flutter.dart';

class AuthServices {
  final SupabaseClient _supabase = Supabase.instance.client;

  //Sign in
  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _supabase.auth.signInWithPassword(
      password: password,
      email: email,
    );
  }

  //Sign up
  Future<AuthResponse> signUpWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }
  //Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
  //Get user email
  String? getCurrentUserEmail(){
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  String? getCurrentUserId() {
    return _supabase.auth.currentUser?.id;
  }
}