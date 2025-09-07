import 'package:flutter/material.dart';
import 'package:hostel_management/Const/font_weight_const.dart';
import 'package:hostel_management/Widgets/Text/inter_text_widget.dart';

class CalendarPopup extends StatefulWidget {
  final Function(DateTime?, DateTime?, int, int)? onApply;
  final VoidCallback? onCancel;
  final AnimationController? animationController;

  const CalendarPopup({
    super.key,
    this.onApply,
    this.onCancel,
    this.animationController,
  });

  // Static method to show the calendar popup
  static Future<void> show(
    BuildContext context, {
    Function(DateTime?, DateTime?, int, int)? onApply,
    VoidCallback? onCancel,
    AnimationController? animationController,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return CalendarPopup(
          onApply: onApply,
          onCancel: onCancel,
          animationController: animationController,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1), // Start from bottom
            end: Offset.zero, // End at center
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<CalendarPopup> createState() => _CalendarPopupState();
}

class _CalendarPopupState extends State<CalendarPopup> {
  DateTime? checkInDate = DateTime.now();
  DateTime? checkOutDate;
  int guests = 1;
  int rooms = 1;
  DateTime currentMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );
  bool isSelectingMonth = false;
  bool isSelectingYear = false;

  String _formatDate(DateTime? date) {
    if (date == null) return '--';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  int _calculateNights() {
    if (checkInDate == null || checkOutDate == null) return 0;
    return checkOutDate!.difference(checkInDate!).inDays;
  }

  List<Widget> _buildCalendarDays(DateTime monthDate) {
    final firstDayOfMonth = DateTime(monthDate.year, monthDate.month, 1);
    final lastDayOfMonth = DateTime(monthDate.year, monthDate.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;

    List<Widget> dayWidgets = [];

    // Add empty cells for days before the first day of the month
    for (int i = 0; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 40, height: 40));
    }

    // Add days of the month
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final currentDate = DateTime(monthDate.year, monthDate.month, day);
      final isCheckIn =
          checkInDate != null &&
          currentDate.year == checkInDate!.year &&
          currentDate.month == checkInDate!.month &&
          currentDate.day == checkInDate!.day;
      final isCheckOut =
          checkOutDate != null &&
          currentDate.year == checkOutDate!.year &&
          currentDate.month == checkOutDate!.month &&
          currentDate.day == checkOutDate!.day;
      final isInRange =
          checkInDate != null &&
          checkOutDate != null &&
          currentDate.isAfter(checkInDate!) &&
          currentDate.isBefore(checkOutDate!);

      dayWidgets.add(
        GestureDetector(
          onTap: () => _selectDate(currentDate),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  isCheckIn || isCheckOut
                      ? Colors.blue
                      : isInRange
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.transparent,
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color:
                      isCheckIn || isCheckOut
                          ? Colors.white
                          : isInRange
                          ? Colors.blue
                          : Colors.black87,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return dayWidgets;
  }

  void _selectDate(DateTime selectedDate) {
    setState(() {
      if (checkInDate == null ||
          (checkInDate != null && checkOutDate != null)) {
        checkInDate = selectedDate;
        checkOutDate = null;
      } else if (selectedDate.isAfter(checkInDate!)) {
        checkOutDate = selectedDate;
      } else {
        checkInDate = selectedDate;
        checkOutDate = null;
      }
    });
  }

  Widget _buildYearSelector() {
    final currentYear = DateTime.now().year;
    final years = List.generate(10, (index) => currentYear - 5 + index);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Select Year',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: years.length,
              itemBuilder: (context, index) {
                final year = years[index];
                final isSelected = year == currentMonth.year;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      currentMonth = DateTime(year, currentMonth.month, 1);
                      isSelectingYear = false;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        year.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Select Month',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final isSelected = index + 1 == currentMonth.month;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      currentMonth = DateTime(currentMonth.year, index + 1, 1);
                      isSelectingMonth = false;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        months[index].substring(0, 3),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarMonth(DateTime monthDate) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    const weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Column(
      children: [
        // Month header - clickable
        GestureDetector(
          onTap: () {
            setState(() {
              if (isSelectingYear) {
                isSelectingYear = false;
              } else {
                isSelectingMonth = !isSelectingMonth;
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${months[monthDate.month - 1]} ',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  (isSelectingMonth)
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey[600],
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelectingMonth) {
                        isSelectingMonth = false;
                      } else {
                        isSelectingYear = !isSelectingYear;
                      }
                    });
                  },
                  child: Text(
                    '${monthDate.year}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isSelectingYear ? Colors.blue : Colors.black,
                      decoration:
                          isSelectingYear ? TextDecoration.underline : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelectingMonth) {
                        isSelectingMonth = false;
                      } else {
                        isSelectingYear = !isSelectingYear;
                      }
                    });
                  },
                  child: Icon(
                    (isSelectingYear)
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),

        if (!isSelectingMonth && !isSelectingYear) ...[
          // Week day headers
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children:
                  weekDays
                      .map(
                        (day) => SizedBox(
                          width: 40,
                          child: Center(
                            child: Text(
                              day,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),

          // Calendar grid
          Wrap(children: _buildCalendarDays(monthDate)),
        ],

        if (isSelectingMonth) _buildMonthSelector(),
        if (isSelectingYear) _buildYearSelector(),

        const SizedBox(height: 30),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final secondMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        constraints: const BoxConstraints(maxHeight: 650),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fixed Header with check-in/check-out
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.transparent,
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 0.2),
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Check-in/Check-out selector
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                InterTextWidget(
                                  text: 'Check In',
                                  fontSize: 15,
                                  color: const Color(0xFF1A4D99),
                                  fontWeight: FontWeightConst.semiBold,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatDate(checkInDate),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A4D99),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Column(
                              children: [
                                InterTextWidget(
                                  text: 'Check Out',
                                  fontSize: 15,
                                  color: const Color(0xFF000000),
                                  fontWeight: FontWeightConst.semiBold,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatDate(checkOutDate),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF000000),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (checkInDate != null && checkOutDate != null) ...[
                    const SizedBox(height: 12),
                    InterTextWidget(
                      text: '${_calculateNights()} nights selected',
                      fontSize: 14,
                      fontWeight: FontWeightConst.bold,
                      color: const Color(0xFFFFFFFF),
                    ),
                  ],
                ],
              ),
            ),

            // Scrollable Calendar content
            Expanded(
              child: Container(
                decoration: const BoxDecoration(color: Colors.transparent),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Calendar months container
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 0,
                        ),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildCalendarMonth(currentMonth),
                            if (!isSelectingMonth && !isSelectingYear)
                              _buildCalendarMonth(secondMonth),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Fixed Guests and Rooms section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Guests
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Guests',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (guests > 1) {
                                  setState(() {
                                    guests--;
                                  });
                                }
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: const Icon(
                                  Icons.remove,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              guests.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  guests++;
                                });
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  Divider(color: Colors.grey[200]),

                  // Rooms
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Rooms',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (rooms > 1) {
                                  setState(() {
                                    rooms--;
                                  });
                                }
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: const Icon(
                                  Icons.remove,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              rooms.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  rooms++;
                                });
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Fixed Bottom buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onCancel?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.pink,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onApply?.call(
                          checkInDate,
                          checkOutDate,
                          guests,
                          rooms,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Apply',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
