import 'package:flutter/material.dart';

class PetugasDashboard extends StatelessWidget {
  const PetugasDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Petugas'),
        automaticallyImplyLeading: false,
      ),
      body: const SafeArea(
        child: Center(child: Text('Area petugas')),
      ),
    );
  }
}
