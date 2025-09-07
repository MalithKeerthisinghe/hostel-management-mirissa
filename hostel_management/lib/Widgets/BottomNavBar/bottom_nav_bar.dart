import 'package:flutter/material.dart';
import 'package:hostel_management/Const/font_weight_const.dart';
import 'package:hostel_management/Widgets/Text/inter_text_widget.dart';

class BottomNavigationBarComponent extends StatelessWidget {
  final bool isHomeActive;
  final Function(int)? onItemSelected;

  const BottomNavigationBarComponent({
    super.key,
    this.isHomeActive = true,
    this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomNavItem(
            'assets/bottom_nav/house.png',
            'Home',
            0,
            isHomeActive,
          ),
          _buildBottomNavItem('assets/bottom_nav/booking.png', '', 1, false),
          _buildBottomNavItem('assets/bottom_nav/save.png', '', 2, false),
          _buildBottomNavItem('assets/bottom_nav/profile.png', '', 3, false),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(
    String path,
    String text,
    int index,
    bool isActive,
  ) {
    return GestureDetector(
      onTap: () => onItemSelected?.call(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Image(
              image: AssetImage(path),
              width: 24,
              height: 24,
              color: isActive ? Colors.blue : Colors.grey,
            ),
            const SizedBox(width: 4),
            if (isActive)
              InterTextWidget(
                text: text,
                fontSize: 10,
                color: isActive ? Colors.blue : Colors.grey,
                fontWeight: FontWeightConst.semiBold,
              ),
          ],
        ),
      ),
    );
  }
}
