import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
        automaticallyImplyLeading: false,
      ),
      body: const SafeArea(
        child: Center(child: Text('Area admin')),
      ),
    );
  }
}
