import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart'; // <-- Add this
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
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        ScalePageRoute(page: const OnBoardScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset('assets/splash_logo.png')
                .animate(
                  onPlay: (controller) => controller.forward(),
                ) // repeat loop
                .scale(
                  duration: 800.ms,
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1.9, 1.9),
                  curve: Curves.ease,
                ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 10,
        ),
        child: Text(
          'Copy Rights by Book Now',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
