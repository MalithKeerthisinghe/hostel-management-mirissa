import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hostel_management/Screens/OnBoardScreens/on_board_screen.dart';
import 'package:hostel_management/Widgets/PageRoute/custom_page_route.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.push(context, ScalePageRoute(page: OnBoardScreen()));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Image(image: AssetImage('assets/splash_logo.png'))),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 10,
        ),
        child: Text(
          'Copy Rights by Book Now ',

          textAlign: TextAlign.center,
          // style: TextStyle(
          //   fontSize: 16,
          //   color: Color(0xFF000000),
          //   fontWeight: FontWeight.w500,
          //   letterSpacing: 0.5,
          // ),
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Color(0xFF000000),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
