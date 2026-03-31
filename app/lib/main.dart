import 'package:flutter/material.dart';

import 'package:kassa/pages/home.dart';

void main() {
  runApp(const Kassa());
}

class Kassa extends StatelessWidget {
  const Kassa({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomePage());
  }
}
