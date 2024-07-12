import 'package:flutter/material.dart';
import 'package:video_editing_app/UI/splacescreen/splacescreen.dart';
import 'package:video_editing_app/themes/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: def,
      home: SplashScreen(),
    );
  }
}
