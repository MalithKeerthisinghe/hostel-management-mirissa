import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hostel_management/Const/font_weight_const.dart';
import 'package:hostel_management/Screens/AuthScreen/create_new_password.dart';
import 'package:hostel_management/Screens/AuthScreen/otp_verification_screen.dart';
import 'package:hostel_management/Screens/HomeScreen/home_screen.dart';
import 'package:hostel_management/Services/auth_service.dart';
import 'package:hostel_management/Widgets/PageRoute/custom_page_route.dart';
import 'package:hostel_management/Widgets/Text/inter_text_widget.dart';
import 'package:hostel_management/Widgets/TextBox/custom_text_box.dart';
import 'package:hostel_management/Widgets/gradient_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _otpController =
      TextEditingController(); // Add OTP controller

  bool _isLoading = false;
  String _errorMessage = '';

  // Focus nodes to manage keyboard
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  final FocusNode _firstNameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _showErrorMessage(String message) {
    setState(() {
      _errorMessage = message;
    });

    // Auto clear after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _errorMessage = '';
        });
      }
    });
  }

  void _handleTabChange() {
    // Hide keyboard when tab changes
    FocusManager.instance.primaryFocus?.unfocus();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _firstNameController.clear();
    _otpController.clear();

    // Clear error message when changing tabs
    if (_errorMessage.isNotEmpty) {
      _showErrorMessage('');
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _otpController.dispose();

    // Dispose focus nodes
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _firstNameFocusNode.dispose();

    super.dispose();
  }

  // Show loading dialog
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Processing..."),
              ],
            ),
          ),
        );
      },
    );
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Handle sign in
  Future<void> _handleSignIn() async {
    // Hide keyboard when submitting
    FocusManager.instance.primaryFocus?.unfocus();

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorMessage('Please fill all fields');
      return;
    }
    _showErrorMessage('');
    setState(() {
      _isLoading = true;
    });

    _showLoadingDialog();

    try {
      final response = await ApiService.login(
        _emailController.text,
        _passwordController.text,
      );
      print('Registration successful: ${response['message']}');
      Navigator.of(context).pop(); // Close loading dialog
      Navigator.push(context, ScalePageRoute(page: HomeScreen()));
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog

      _showErrorMessage(e.toString());
      _showErrorDialog(_errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Handle sign up
  Future<void> _handleSignUp() async {
    // Hide keyboard when submitting
    FocusManager.instance.primaryFocus?.unfocus();

    if (_firstNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showErrorMessage('Please fill all fields');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorMessage('Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
    });
    _showErrorMessage('');

    _showLoadingDialog();

    try {
      final response = await ApiService.register(
        _emailController.text,
        _passwordController.text,
      );

      Navigator.of(context).pop(); // Close loading dialog
      Navigator.push(context, ScalePageRoute(page: HomeScreen()));
      // Navigate to home screen or perform other actions
      print('Registration successful: ${response['message']}');
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog

      _showErrorMessage(e.toString());
      _showErrorDialog(_errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Handle forgot password
  Future<void> _handleForgotPassword() async {
    print('Forgot password for email: ${_emailController.text} $_isLoading');
    // Hide keyboard when submitting
    FocusManager.instance.primaryFocus?.unfocus();

    if (_emailController.text.isEmpty) {
      _showErrorMessage('Please enter your email');
      return;
    }

    setState(() {
      _isLoading = true;
    });
    _showErrorMessage('');

    _showLoadingDialog();

    try {
      final response = await ApiService.forgotPassword(_emailController.text);
      print('Forgot password response: ${response['message']}');
      Navigator.of(context).pop(); // Close loading dialog

      if (response['success'] == 'OTP sent to email') {
        // Navigate to OTP verification screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    OTPVerificationScreen(email: _emailController.text),
          ),
        );
      } else {
        print('Response body: ${response['message']}');
        _showErrorMessage(response['message'] ?? 'Failed to send OTP');
        _showErrorDialog(_errorMessage);
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog

      _showErrorMessage(e.toString());
      _showErrorDialog(_errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildSocialButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 46,
        height: 46,
        decoration: ShapeDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.50, -0.00),
            end: Alignment(0.50, 1.00),
            colors: [const Color(0xFF00B1D6), const Color(0xFF00358D)],
          ),
          shape: OvalBorder(),
        ),
        child: Image(image: AssetImage(text)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.12),
                  // Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    child: Center(
                      child: Image(image: AssetImage('assets/splash_logo.png')),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Welcome Text
                  InterTextWidget(
                    text: 'Welcome',
                    fontSize: 24,
                    color: Color(0xFF111827),
                    fontWeight: FontWeightConst.bold,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sign in to your account or create a new one',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Color(0xFF4B5563),
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32),

                  // Tab Bar
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 24),
                    child: TabBar(
                      controller: _tabController,
                      dividerColor: Colors.transparent,
                      labelColor: Color(0xFF111827),
                      unselectedLabelColor: Color(0xFF9CA3AF),
                      automaticIndicatorColorAdjustment: false,
                      labelStyle: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      labelPadding: EdgeInsets.symmetric(horizontal: 4),
                      unselectedLabelStyle: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      indicatorColor: Color(0xFF0EA5E9),
                      indicatorWeight: 2,
                      tabs: [
                        Tab(text: 'Sign In'),
                        Tab(text: 'Sign Up'),
                        Tab(text: 'Forgot Password?'),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Error message
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (_errorMessage.isNotEmpty) SizedBox(height: 12),

                  // Tab Bar View - Remove Expanded and give it a fixed height
                  SizedBox(
                    height:
                        MediaQuery.of(context).size.height *
                        0.6, // Adjust this value as needed
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildSignInTab(),
                        _buildSignUpTab(),
                        _buildForgotPasswordTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInTab() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          CustomTextFromBox(
            labelText: 'Enter your email',
            controller: _emailController,
            focusNode: _emailFocusNode,
          ),
          CustomTextFromBox(
            labelText: 'Enter your password',
            isPassword: true,
            controller: _passwordController,
            focusNode: _passwordFocusNode,
          ),
          SizedBox(height: 12),

          GestureDetector(
            onTap: _isLoading ? null : _handleSignIn,
            child: GradientButton(
              text: 'Sign In',
              width: MediaQuery.of(context).size.width,
            ),
          ),

          SizedBox(height: 24),

          // Divider with or sign methods
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 62,
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      strokeAlign: BorderSide.strokeAlignCenter,
                      color: const Color(0xFFE8EAEC),
                    ),
                  ),
                ),
              ),

              SizedBox(width: 12),
              InterTextWidget(
                text: 'Or Sign In with',
                fontSize: 14,
                color: Color(0xFF9CA4AB),
                fontWeight: FontWeightConst.regular,
              ),
              SizedBox(width: 12),
              Container(
                width: 62,
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      strokeAlign: BorderSide.strokeAlignCenter,
                      color: const Color(0xFFE8EAEC),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton(text: 'assets/google.png', onPressed: () {}),
              SizedBox(width: 48),
              _buildSocialButton(text: 'assets/facebook.png', onPressed: () {}),
            ],
          ),

          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 10,
            ),
            child: Text.rich(
              TextSpan(
                text: 'By signing up you agree to our\n ',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Color(0xFF78828A),
                ),
                children: [
                  TextSpan(
                    text: 'Terms',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Color(0xFF171725),
                    ),
                  ),
                  TextSpan(
                    text: ' and ',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Color(0xFF78828A),
                    ),
                  ),
                  TextSpan(
                    text: 'Conditions of Use',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Color(0xFF171725),
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpTab() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          children: [
            CustomTextFromBox(
              labelText: 'Enter your first name',
              controller: _firstNameController,
              focusNode: _firstNameFocusNode,
            ),
            CustomTextFromBox(
              labelText: 'Enter your email',
              controller: _emailController,
              focusNode: _emailFocusNode,
            ),
            CustomTextFromBox(
              labelText: 'Enter your password',
              isPassword: true,
              controller: _passwordController,
              focusNode: _passwordFocusNode,
            ),
            CustomTextFromBox(
              labelText: 'Confirm your password',
              isPassword: true,
              controller: _confirmPasswordController,
              focusNode: _confirmPasswordFocusNode,
            ),
            SizedBox(height: 8),

            GestureDetector(
              onTap: _isLoading ? null : _handleSignUp,
              child: GradientButton(
                text: 'Sign UP',
                width: MediaQuery.of(context).size.width,
              ),
            ),

            SizedBox(height: 24),
            Text(
              'Or Sign up with',
              style: GoogleFonts.inter(fontSize: 14, color: Color(0xFF9CA3AF)),
            ),
            SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialButton(text: 'assets/google.png', onPressed: () {}),
                SizedBox(width: 48),
                _buildSocialButton(
                  text: 'assets/facebook.png',
                  onPressed: () {},
                ),
              ],
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 10,
              ),
              child: Text.rich(
                TextSpan(
                  text: 'By signing up you agree to our\n ',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Color(0xFF78828A),
                  ),
                  children: [
                    TextSpan(
                      text: 'Terms',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Color(0xFF171725),
                      ),
                    ),
                    TextSpan(
                      text: ' and ',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Color(0xFF78828A),
                      ),
                    ),
                    TextSpan(
                      text: 'Conditions of Use',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Color(0xFF171725),
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForgotPasswordTab() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Column(
        children: [
          CustomTextFromBox(
            labelText: 'Enter your email',
            controller: _emailController,
            focusNode: _emailFocusNode,
          ),
          SizedBox(height: 8),

          GestureDetector(
            onTap: _isLoading ? null : _handleForgotPassword,
            child: GradientButton(
              text: 'Next',
              width: MediaQuery.of(context).size.width,
            ),
          ),
          SizedBox(height: 100),
        ],
      ),
    );
  }
}
