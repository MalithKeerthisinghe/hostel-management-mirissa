import 'package:flutter/material.dart';
import 'package:hostel_management/Screens/AuthScreen/auth_screen.dart';
import 'package:hostel_management/Screens/OnBoardScreens/on_board_screen.dart';
import 'package:hostel_management/Screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SplashScreen(),
    );
  }
}
