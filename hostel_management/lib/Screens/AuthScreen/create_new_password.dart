import 'package:flutter/material.dart';
import 'package:hostel_management/Const/font_weight_const.dart';
import 'package:hostel_management/Widgets/Text/inter_text_widget.dart';
import 'package:hostel_management/Widgets/TextBox/custom_text_box.dart';
import 'package:hostel_management/Widgets/gradient_button.dart';

class CreateNewPassword extends StatefulWidget {
  const CreateNewPassword({super.key});

  @override
  State<CreateNewPassword> createState() => _CreateNewPasswordState();
}

class _CreateNewPasswordState extends State<CreateNewPassword> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
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
        child: Center(
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.12),
              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  //color: Color(0xFF0EA5E9),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image(image: AssetImage('assets/splash_logo.png')),
                ),
              ),
              SizedBox(height: 24),
              InterTextWidget(
                text: 'Welcome',
                fontSize: 24,
                color: Color(0xFF111827),
                fontWeight: FontWeightConst.bold,
              ),
              SizedBox(height: 8),
              InterTextWidget(
                text: 'Create a\nNew Password',
                fontSize: 24,
                color: Color(0xFF111827),
                fontWeight: FontWeightConst.bold,
              ),

              SizedBox(height: 8),
              InterTextWidget(
                text: 'Enter your new password',
                fontSize: 16,
                color: Color(0xFF434E58),
                fontWeight: FontWeightConst.regular,
              ),
              SizedBox(height: 8),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CustomTextFromBox(
                        labelText: 'Enter your email',
                        isPassword: false,
                        controller: _emailController,
                      ),
                      SizedBox(height: 8),
                      CustomTextFromBox(
                        labelText: 'Enter your password',
                        isPassword: true,
                        controller: _passwordController,
                      ),
                      SizedBox(height: 8),
                      GradientButton(
                        text: 'Next',
                        width: MediaQuery.of(context).size.width,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
