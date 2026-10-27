import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Smart Class",
      home: Scaffold(
        appBar: AppBar(
          title: Text("Appbar aplikasi"),
          backgroundColor: const Color.fromARGB(
            255,
            2,
            92,
            196,
          ),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          margin: EdgeInsets.all(20),
          color: Colors.amberAccent,
          width: 100,
          height: 100,
          child: Text("Text ini ajdfhajs dhfajdfh"),
        ),

        bottomNavigationBar: Text("ini bagian bottom"),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
