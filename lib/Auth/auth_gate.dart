/*

uncauthenticated => login page
authenticated => Profile page

*/

import 'package:flutter/material.dart';
import 'package:flutter03/pages/auth_page.dart/loginPage.dart';
import 'package:flutter03/pages/profilePage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      //Listen to auth state changes
      stream: Supabase.instance.client.auth.onAuthStateChange,

      //Build Apropriate page base on auth state
      builder: (context, snapshot) {
        //if loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          return const ProfilePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
