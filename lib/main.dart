import 'package:admin_dashboards/dashboard/side_navigation_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'authentication/login_screen.dart';

void main() async
{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyBZ2XV4A8wn-qTTOGQLnPu5cAuXdIXiHeQ',
        appId: '1:832713560007:android:8cd12b1b74fba1478953e2',
        messagingSenderId: '832713560007',
        projectId: 'be-right-there-f7e78',
        databaseURL: 'https://be-right-there-f7e78-default-rtdb.asia-southeast1.firebasedatabase.app',
      )
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conditional Navigation Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthWrapper(), // Entry point to check auth status
      routes:  {
       '/home': (context) =>  SideNavigationDrawer(),
      '/login': (context) => LoginScreen(),
       '/unauthorized': (context) =>  UnauthorizedScreen(),
     },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<bool> _checkIsAdmin(String uid) async {
    // Retrieve the admin status from the database (modify this path as per your schema)
    DatabaseReference ref = FirebaseDatabase.instance.ref("users/$uid");
    DatabaseEvent event = await ref.once();
    final data = event.snapshot.value as Map<dynamic, dynamic>?;

    return data?['isAdmin'] == true;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          // If user is authenticated, check if they are an admin
          return FutureBuilder<bool>(
            future: _checkIsAdmin(snapshot.data!.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError || !snapshot.hasData || !snapshot.data!) {
                // Not authorized (admin status is false or not available)
                return const UnauthorizedScreen();
              } else {
                // Admin access confirmed
                return const SideNavigationDrawer();
              }
            },
          );
        } else {
          // No user signed in, go to login screen
          return  LoginScreen();
        }
      },
    );
  }
}

class UnauthorizedScreen extends StatelessWidget {
  const UnauthorizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      // Redirect to login after 2 seconds
      Navigator.of(context).pushReplacementNamed('/login');
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Unauthorized')),
      body: const Center(
        child: Text(
          'Unauthorized access. Redirecting to login...',
          style: TextStyle(fontSize: 18, color: Colors.red),
        ),
      ),
    );
  }
}



