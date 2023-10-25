import 'package:flutter/material.dart';
import 'pages/home.dart';

List <Habit> habits = [];

void main() => runApp(const NURGENT());

class NURGENT extends StatelessWidget {
  const NURGENT({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(fontFamily: 'Poppins'),
      home: const HomePage(),
    );
  }
}

class Habit{
  String name;
  int streak;

  Habit({required this.name, this.streak = 0});

}

