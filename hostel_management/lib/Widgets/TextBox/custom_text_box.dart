import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextFromBox extends StatefulWidget {
  final String labelText;
  final bool isPassword;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  const CustomTextFromBox({
    super.key,
    required this.labelText,
    this.isPassword = false,
    this.controller,
    this.focusNode,
  });

  @override
  State<CustomTextFromBox> createState() => _CustomTextFromBoxState();
}

class _CustomTextFromBoxState extends State<CustomTextFromBox> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Color(0xFF3B82F6), // cursor
            selectionColor: Color(
              0x553B82F6,
            ), // text highlight (semi-transparent)
            selectionHandleColor: Color(0xFF3B82F6), // little drag handles
          ),
        ),
        child: TextField(
          focusNode: widget.focusNode,
          controller: widget.controller,
          cursorColor: const Color(0xFF3B82F6), // redundant but safe
          obscureText: widget.isPassword && !_isPasswordVisible,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: const Color(0xFF374151),
          ),
          decoration: InputDecoration(
            fillColor: const Color(0xFFF9FAFB),
            filled: true,
            suffixIcon:
                widget.isPassword
                    ? IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xFF9CA3AF),
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    )
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
            ),
            labelText: widget.labelText,
            labelStyle: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
              fontWeight: FontWeight.w400,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }
}
