import 'package:admin_dashboards/dashboard/side_navigation_drawer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

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

class MyApp extends StatelessWidget
{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin Panel',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SideNavigationDrawer(),
    );
  }
}


