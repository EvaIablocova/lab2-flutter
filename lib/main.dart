import 'package:flutter/material.dart';
import 'main_screen.dart';

void main() {
  runApp(const OrganizerApp());
}

class OrganizerApp extends StatelessWidget {
  const OrganizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Organizer Lab2',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
