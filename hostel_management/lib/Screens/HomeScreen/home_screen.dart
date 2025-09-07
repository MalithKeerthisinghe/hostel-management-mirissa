import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hostel_management/Const/font_weight_const.dart';
import 'package:hostel_management/Widgets/BottomNavBar/bottom_nav_bar.dart';
import 'package:hostel_management/Widgets/Calender/calender_pop_up.dart';
import 'package:hostel_management/Widgets/Text/inter_text_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool isSearchExpanded = false;
  int selectedTabIndex = 0; // 0 for Activities, 1 for Hostels
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final TextEditingController _searchController = TextEditingController();

  late AnimationController _calendarAnimationController;
  late Animation<double> _calendarScaleAnimation;
  late Animation<Offset> _calendarSlideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _calendarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _calendarScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _calendarAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _calendarSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _calendarAnimationController,
        curve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showAnimatedCalendar() async {
    // Start the animation
    _calendarAnimationController.forward();

    // Show calendar with custom animation
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SlideTransition(
          position: _calendarSlideAnimation,
          child: ScaleTransition(
            scale: _calendarScaleAnimation,
            child: CalendarPopup(
              onApply: (checkIn, checkOut, guests, rooms) {
                // Handle the selected values
                print('Check-in: $checkIn');
                print('Check-out: $checkOut');
                print('Guests: $guests');
                print('Rooms: $rooms');

                // Reset animation
                _calendarAnimationController.reset();
              },
              onCancel: () {
                print('Calendar cancelled');
                // Reset animation
                _calendarAnimationController.reset();
              },
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  void toggleSearch() {
    setState(() {
      isSearchExpanded = !isSearchExpanded;
      if (isSearchExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
        _searchController.clear();
      }
    });
  }

  void selectTab(int index) {
    setState(() {
      selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main content
          FadeTransition(opacity: _fadeAnimation, child: _buildMainContent()),
          // Search overlay
          if (isSearchExpanded)
            ScaleTransition(
              scale: _scaleAnimation,
              child: _buildSearchOverlay(),
            ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SafeArea(
      child: Column(
        children: [
          // Top bar with tabs
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    gradient: LinearGradient(
                      colors: [Color(0xFFA4EFFF), Color(0xFF00358D)],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage('assets/img.png'),
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.13),
                GestureDetector(
                  onTap: () => selectTab(0),
                  child: InterTextWidget(
                    text: 'Activities',
                    fontSize: 20,
                    fontWeight: FontWeightConst.semiBold,
                    color:
                        selectedTabIndex == 0
                            ? Color(0xFF1F1B1B)
                            : Color(0xFFAB9E9E),
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.1),
                GestureDetector(
                  onTap: () => selectTab(1),
                  child: InterTextWidget(
                    text: 'Hostels',
                    fontSize: 20,
                    fontWeight: FontWeightConst.semiBold,
                    color:
                        selectedTabIndex == 1
                            ? Color(0xFF1F1B1B)
                            : Color(0xFFAB9E9E),
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: toggleSearch,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      // color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Image(
                      image: AssetImage('assets/search.png'),
                      width: 24,
                      height: 24,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Filter tags (only show for Activities)
          if (selectedTabIndex == 0) _buildFilterTags(),

          // Content based on selected tab
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child:
                  selectedTabIndex == 0
                      ? _buildActivitiesGrid()
                      : _buildHostelsGrid(),
            ),
          ),
          // Bottom navigation
          BottomNavigationBarComponent(
            isHomeActive: true,
            onItemSelected: (index) {
              // Handle navigation item selection
              print('Selected index: $index');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTags() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterTag('Whale Watching', true),
          SizedBox(width: 12),
          _buildFilterTag('Diving', false),
          SizedBox(width: 12),
          _buildFilterTag('Surf Lesson', false),
        ],
      ),
    );
  }

  Widget _buildFilterTag(String text, bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        // color: isSelected ? Colors.blue : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFF1A4D99), width: 1),
      ),
      child: InterTextWidget(
        text: text,
        fontSize: 13,
        color: Color(0xFF1A4D99),
        fontWeight: FontWeightConst.semiBold,
        letterSpacing: 0,
      ),
    );
  }

  Widget _buildActivitiesGrid() {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.5,
        children: [
          _buildActivityCard(
            '4.8',
            'assets/activity_card.png',

            '\$12',
            '2-3 hrs',
            '11',
            'Whale Watching Club Mirissa',
            'Mirissa',
            false,
            true,
            'assets/activity_ownwe.png',
          ),
          _buildActivityCard(
            '5.0',
            'assets/activity_card.png',

            '\$25',
            '4-5 hrs',
            '8',
            'Charly\'s Surf School Club Mirissa',
            'Mirissa',
            false,
            false,
            'assets/activity_ownwe.png',
          ),
          _buildActivityCard(
            '4.6',
            'assets/activity_card.png',

            '\$15',
            '2-3 hrs',
            '15',
            'Whale Watching Club Mirissa',
            'Mirissa',
            true,
            false,
            'assets/activity_ownwe.png',
          ),
          _buildActivityCard(
            '4.5',
            'assets/activity_card.png',

            '\$30',
            '3-4 hrs',
            '12',
            'Diving School Club Mirissa',
            'Mirissa',
            false,
            false,
            'assets/activity_ownwe.png',
          ),
        ],
      ),
    );
  }

  Widget _buildHostelsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 0.5,
      children: [
        _buildHostelCard(
          '4.8',
          'assets/home_card.png',

          '\$10',
          '\$30',
          '11',
          'Hostel Five Minus',
          'Hangover Hostels',
          'assets/hostel1st.png',
        ),
        _buildHostelCard(
          '4.5',
          'assets/home_card.png',

          '\$15',
          '\$45',
          '8',
          'Hostel Five Minus',
          'Hangover Hostels',
          'assets/hostel1st.png',
        ),
        _buildHostelCard(
          '4.6',
          'assets/home_card.png',

          '\$12',
          '\$35',
          '15',
          'JJ Hostel Mirissa',
          'SATORI BEACH HOUSE',
          'assets/hostel1st.png',
        ),
        _buildHostelCard(
          '4.9',
          'assets/home_card.png',

          '\$18',
          '\$55',
          '12',
          'JJ Hostel Mirissa',
          'SATORI BEACH HOUSE',
          'assets/hostel1st.png',
        ),
      ],
    );
  }

  Widget _buildSearchOverlay() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Search bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),

              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                      gradient: LinearGradient(
                        colors: [Color(0xFFA4EFFF), Color(0xFF00358D)],
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage('assets/img.png'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        onTap: () {
                          _searchController.clear;
                          // In your search icon onTap:
                          _showAnimatedCalendar();
                        },
                        controller: _searchController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: Color(0xFF9E9E9E),
                            fontWeight: FontWeightConst.semiBold,
                          ),
                          hintText:
                              selectedTabIndex == 0
                                  ? 'search for activities'
                                  : 'search for places or property',
                          prefixIcon: Image(
                            image: AssetImage('assets/search.png'),
                            width: 20,
                            height: 20,
                            color: Color(0xFF666666),
                          ),
                          suffixIcon: Image(
                            image: AssetImage('assets/location_48.png'),
                            width: 20,
                            height: 20,
                            color: Color(0xFF666666),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  GestureDetector(
                    onTap: toggleSearch,
                    child: Icon(Icons.close, color: Colors.black87, size: 24),
                  ),
                ],
              ),
            ),
            // Filter tags for activities in search
            if (selectedTabIndex == 0) _buildFilterTags(),
            // Search results
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child:
                    selectedTabIndex == 0
                        ? _buildActivitiesGrid()
                        : _buildHostelsGrid(),
              ),
            ),
            // Bottom navigation
            BottomNavigationBarComponent(
              isHomeActive: true,
              onItemSelected: (index) {
                // Handle navigation item selection
                print('Selected index: $index');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(
    String rating,
    String imageUrl,
    String price,
    String duration,
    String capacity,
    String activityName,
    String location,
    bool trip,
    bool hasWhaleIcon,
    String activityImage,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // Image section
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  // Main image
                  SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: Image.asset(imageUrl, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: SizedBox(
                      width: 63,
                      height: 20,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: 20,
                              height: 20,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(),
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: ShapeDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment(0.50, -0.00),
                                          end: Alignment(0.50, 1.00),
                                          colors: [
                                            const Color(0xFF01ADD3),
                                            const Color(0xFF00388F),
                                          ],
                                        ),
                                        shape: OvalBorder(),
                                      ),
                                      child: Image.asset('assets/PlusMath.png'),
                                    ),
                                  ),
                                  Positioned(
                                    left: 2,
                                    top: 4.67,
                                    child: Container(
                                      width: 15.33,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            "https://placehold.co/15x10",
                                          ),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 12,
                            top: 0,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: ShapeDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    "https://placehold.co/20x20",
                                  ),
                                  fit: BoxFit.cover,
                                ),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: const Color(0xFFEEEEEE),
                                  ),
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                              ),
                              child: Image.asset('assets/img.png'),
                            ),
                          ),
                          Positioned(
                            left: 28,
                            top: 0,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: ShapeDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    "https://placehold.co/20x20",
                                  ),
                                  fit: BoxFit.cover,
                                ),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: const Color(0xFFEEEEEE),
                                  ),
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                              ),
                              child: Image.asset('assets/img.png'),
                            ),
                          ),
                          Positioned(
                            left: 43,
                            top: 0,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: ShapeDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    "https://placehold.co/20x20",
                                  ),
                                  fit: BoxFit.cover,
                                ),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: const Color(0xFFEEEEEE),
                                  ),
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                              ),
                              child: Image.asset('assets/img.png'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Rating badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.yellow, size: 14),
                          SizedBox(width: 4),
                          Text(
                            rating,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Tags overlay on image
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tags row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InterTextWidget(
                              text: 'P/P',
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeightConst.semiBold,
                            ),
                            SizedBox(width: 4),
                            InterTextWidget(
                              text: 'Duration',
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeightConst.semiBold,
                            ),
                            SizedBox(width: 4),
                            InterTextWidget(
                              text: 'Include',
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeightConst.semiBold,
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        // Price row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              price,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4),
                            Row(
                              children: [
                                Image.asset(
                                  'assets/waiting_time.png',
                                  width: 8,
                                  height: 12,
                                ),
                                SizedBox(width: 3),
                                Text(
                                  duration,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 4),
                            trip
                                ? Image.asset(
                                  'assets/trip_vehicle.png',
                                  width: 50,
                                  height: 20,
                                )
                                : hasWhaleIcon
                                ? Image.asset(
                                  'assets/surfe.png',
                                  width: 50,
                                  height: 20,
                                )
                                : Image.asset(
                                  'assets/Cutlery.png',
                                  width: 50,
                                  height: 20,
                                ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // White bottom section
            Container(
              padding: EdgeInsets.all(12),
              color: Colors.white,
              child: Row(
                children: [
                  // Logo/Avatar
                  Image.asset(activityImage, width: 30, height: 30),
                  SizedBox(width: 12),
                  // Hostel name
                  Expanded(
                    child: Text(
                      activityName,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildHostelCard(
    String rating,
    String imageUrl,
    String price1,
    String price2,
    String beds,
    String hostelName,
    String location,
    String hostelImg,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // Image section
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  // Main image
                  SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: Image.asset(imageUrl, fit: BoxFit.cover),
                  ),
                  // Rating badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.yellow, size: 14),
                          SizedBox(width: 4),
                          Text(
                            rating,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Tags overlay on image
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tags row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InterTextWidget(
                              text: 'Dorm',
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeightConst.semiBold,
                            ),
                            SizedBox(width: 4),
                            InterTextWidget(
                              text: 'Private',
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeightConst.semiBold,
                            ),
                            SizedBox(width: 4),
                            InterTextWidget(
                              text: 'Availabe',
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeightConst.semiBold,
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        // Price row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              price1,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              price2,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4),
                            Image.asset(
                              'assets/Cutlery.png',
                              width: 50,
                              height: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // White bottom section
            Container(
              padding: EdgeInsets.all(12),
              color: Colors.white,
              child: Row(
                children: [
                  // Logo/Avatar
                  Image.asset(hostelImg, width: 30, height: 30),
                  SizedBox(width: 12),
                  // Hostel name
                  Expanded(
                    child: Text(
                      hostelName,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
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
