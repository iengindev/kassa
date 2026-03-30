import 'package:flutter/material.dart';

void main() {
  runApp(const Kassa());
}

class Kassa extends StatelessWidget {
  const Kassa({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false);
  }
}
