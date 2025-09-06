import 'package:flutter/material.dart';
import 'package:hostel_management/Const/font_weight_const.dart';
import 'package:hostel_management/Screens/AuthScreen/auth_screen.dart';
import 'package:hostel_management/Widgets/PageRoute/custom_page_route.dart';
import 'package:hostel_management/Widgets/Text/inter_text_widget.dart';
import 'package:hostel_management/Widgets/gradient_button.dart';

class OnBoardScreen extends StatefulWidget {
  const OnBoardScreen({super.key});

  @override
  State<OnBoardScreen> createState() => _OnBoardScreenState();
}

class _OnBoardScreenState extends State<OnBoardScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    // Start initial animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < 2) {
      // Reset animations
      _fadeController.reset();
      _slideController.reset();

      // Move to next page
      _pageController.nextPage(
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );

      // Start animations after a small delay
      Future.delayed(Duration(milliseconds: 200), () {
        _fadeController.forward();
        _slideController.forward();
      });
    }
  }

  Widget _buildDotIndicator(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: 8,
      width: _currentIndex == index ? 24 : 8,
      decoration: BoxDecoration(
        color:
            _currentIndex == index
                ? Color(0xFFB5DBFF)
                : Color(0xFFBFC6CC).withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildAnimatedContent({
    required String mainText,
    required String subText,
    required String buttonText,
    required VoidCallback? onButtonPressed,
    Widget? bottomWidget,
  }) {
    return Stack(
      children: [
        // Main Text with animations
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.3,
          left: 20,
          right: 20,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: InterTextWidget(
                text: mainText,
                color: Color(0xFFFEFEFE),
                fontSize: 24,
                fontWeight: FontWeightConst.bold,
              ),
            ),
          ),
        ),

        // Sub Text with delayed animation
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.25,
          left: 20,
          right: 20,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, 0.5),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _slideController,
                  curve: Interval(0.2, 1.0, curve: Curves.easeOutCubic),
                ),
              ),
              child: InterTextWidget(
                text: subText,
                fontSize: 14,
                color: Color(0xFFE3E9ED),
                fontWeight: FontWeightConst.regular,
              ),
            ),
          ),
        ),

        // Dots indicator with animation
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.20,
          left: 10,
          right: 20,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDotIndicator(0),
                SizedBox(width: 8),
                _buildDotIndicator(1),
                SizedBox(width: 8),
                _buildDotIndicator(2),
              ],
            ),
          ),
        ),

        // Button with animation
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.10,
          left: 10,
          right: 20,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, 1.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _slideController,
                  curve: Interval(0.4, 1.0, curve: Curves.easeOutCubic),
                ),
              ),
              child: GestureDetector(
                onTap: onButtonPressed,
                child: GradientButton(text: buttonText),
              ),
            ),
          ),
        ),

        // Bottom widget (for last page)
        if (bottomWidget != null) bottomWidget,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          // Page 1
          Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Image(
                  image: AssetImage('assets/02_On_Boarding.png'),
                  fit: BoxFit.cover,
                ),
              ),
              _buildAnimatedContent(
                mainText: 'Crash Where it Feels Right',
                subText:
                    'From beachside bunks to city vibes,\n hostels at your fingertips.',
                buttonText: 'Continue',
                onButtonPressed: _nextPage,
              ),
            ],
          ),

          // Page 2
          Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Image(
                  image: AssetImage('assets/03_On_Boarding.png'),
                  fit: BoxFit.cover,
                ),
              ),
              _buildAnimatedContent(
                mainText: 'Connect With Travelers',
                subText:
                    'Meet backpackers, share trips, and make\n new friends on the road.',
                buttonText: 'Continue',
                onButtonPressed: _nextPage,
              ),
            ],
          ),

          // Page 3
          Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Image(
                  image: AssetImage('assets/04_On_Boarding.png'),
                  fit: BoxFit.cover,
                ),
              ),
              _buildAnimatedContent(
                mainText: 'Less Planning, More Living',
                subText:
                    'Stay, connect, explore  one app,one tap endless memories.',
                buttonText: 'Login or Signup',
                onButtonPressed: () {
                  // Navigate to login/signup screen
                  Navigator.push(context, FadePageRoute(page: AuthScreen()));
                  print('Navigate to login/signup');
                },
                bottomWidget: Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.05,
                  left: 10,
                  right: 20,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0, 1.0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _slideController,
                          curve: Interval(0.6, 1.0, curve: Curves.easeOutCubic),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InterTextWidget(
                            text: 'Don\'t have an account? ',
                            fontSize: 14,
                            color: Color(0xFFE3E9ED),
                            fontWeight: FontWeightConst.regular,
                          ),
                          SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              // Navigate to register screen
                              print('Navigate to register');
                            },
                            child: InterTextWidget(
                              text: 'Register',
                              fontSize: 14,
                              color: Color(0xFFB5DBFF),
                              fontWeight: FontWeightConst.regular,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
