import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../methods/common_methods.dart';

class DashboardPage extends StatefulWidget
{
  static const String id = "\webPageDashboard";

  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<DashboardPage>
{
  CommonMethods cMethods = CommonMethods();


  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                alignment: Alignment.topLeft,
                child: const Text(
                  "Admin dashboard",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(
                height: 18,
              ),




            ],
          ),
        ),
      ),
    );
  }
}