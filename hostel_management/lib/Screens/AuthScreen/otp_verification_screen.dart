import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hostel_management/Const/font_weight_const.dart';
import 'package:hostel_management/Widgets/Text/inter_text_widget.dart';
import 'package:hostel_management/Widgets/gradient_button.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;

  const OTPVerificationScreen({super.key, this.email = 'example@gmail.com'});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    // Handle pasted OTP (multiple digits)
    if (value.length > 1) {
      _handlePastedOTP(value, index);
      return;
    }

    // Handle single digit input
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  void _onKeyEvent(KeyEvent event, int index) {
    // Handle backspace/delete for clearing boxes one by one
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace ||
          event.logicalKey == LogicalKeyboardKey.delete) {
        if (_controllers[index].text.isEmpty && index > 0) {
          // If current box is empty and backspace is pressed, go to previous box and clear it
          _focusNodes[index - 1].requestFocus();
          _controllers[index - 1].clear();
        } else if (_controllers[index].text.isNotEmpty) {
          // If current box has text, clear it
          _controllers[index].clear();
        }
        setState(() {});
      }
    }
  }

  void _handlePastedOTP(String pastedText, int startIndex) {
    // Clean the pasted text to only include digits
    String cleanedText = pastedText.replaceAll(RegExp(r'[^0-9]'), '');

    // Limit to 4 digits maximum
    if (cleanedText.length > 4) {
      cleanedText = cleanedText.substring(0, 4);
    }

    // Clear all fields first
    for (var controller in _controllers) {
      controller.clear();
    }

    // Fill the controllers starting from the first box
    for (int i = 0; i < cleanedText.length && i < 4; i++) {
      _controllers[i].text = cleanedText[i];
    }

    // Focus on the next empty box or the last box if all are filled
    if (cleanedText.length < 4) {
      _focusNodes[cleanedText.length].requestFocus();
    } else {
      _focusNodes[3].requestFocus();
    }

    setState(() {});
  }

  bool _isOTPComplete() {
    return _controllers.every((controller) => controller.text.isNotEmpty);
  }

  String _getOTP() {
    return _controllers.map((controller) => controller.text).join();
  }

  void _clearAllFields() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
    setState(() {});
  }

  Widget _buildOTPField(int index) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Color(0xFFF9FAFB),
        border: Border.all(
          color:
              _controllers[index].text.isNotEmpty
                  ? Color(0xFF0EA5E9)
                  : Color(0xFFE5E7EB),
          width: _controllers[index].text.isNotEmpty ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) => _onKeyEvent(event, index),
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
          inputFormatters: [
            // Allow pasting of multiple digits but limit single input to 1 digit
            LengthLimitingTextInputFormatter(4),
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            counterText: '',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) {
            _onChanged(value, index);
          },
          onTap: () {
            _controllers[index].selection = TextSelection.fromPosition(
              TextPosition(offset: _controllers[index].text.length),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true, // This helps with keyboard overflow
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                kToolbarHeight,
          ),
          child: IntrinsicHeight(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.045),

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
                    letterSpacing: 0,
                  ),

                  SizedBox(height: 8),

                  // Enter OTP Text
                  InterTextWidget(
                    text: 'Enter OTP',
                    fontSize: 24,
                    color: Color(0xFF111827),
                    fontWeight: FontWeightConst.bold,
                    letterSpacing: 0.5,
                  ),

                  SizedBox(height: 16),

                  // Description Text
                  Text.rich(
                    TextSpan(
                      text:
                          'We have just sent you 4 digit code via your\nemail ',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Color(0xFF434E58),
                        fontWeight: FontWeight.w400,
                      ),
                      children: [
                        TextSpan(
                          text: widget.email,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Color(0xFF171725),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 38),

                  // OTP Input Fields
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          4,
                          (index) => _buildOTPField(index),
                        ),
                      ),
                      SizedBox(height: 18),

                      // Continue Button
                      _isOTPComplete()
                          ? GestureDetector(
                            onTap: () {
                              // Handle OTP verification
                              String otp = _getOTP();
                              print('OTP entered: $otp');
                              // Add your verification logic here
                            },
                            child: GradientButton(
                              text: 'Continue',
                              width: MediaQuery.of(context).size.width,
                            ),
                          )
                          : Container(
                            width: double.infinity,
                            height: 56,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Color(0xFFE5E7EB),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: InterTextWidget(
                                text: 'Continue',
                                fontSize: 18,
                                color: Color(0xFF9CA3AF),
                                fontWeight: FontWeightConst.semiBold,
                              ),
                            ),
                          ),

                      SizedBox(height: 24),

                      // Resend Code
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Didn\'t receive code? ',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Color(0xFF66707A),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Handle resend code
                              print('Resend code tapped');
                              // Clear fields when resending
                              _clearAllFields();
                            },
                            child: Text(
                              'Resend Code',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Color(0xFF2853AF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Flexible spacer that adjusts when keyboard appears
                  Expanded(child: SizedBox(height: 20)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
