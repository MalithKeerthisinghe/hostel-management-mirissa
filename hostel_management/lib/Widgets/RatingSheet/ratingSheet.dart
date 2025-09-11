import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'loggedRatingSheet.dart';

class RatingSheetTop extends StatefulWidget {
  final bool isLoggedIn;

  const RatingSheetTop({super.key, required this.isLoggedIn});

  static void show(BuildContext context, {required bool isLoggedIn}) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                RatingSheetTop(isLoggedIn: isLoggedIn),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, -1.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  State<RatingSheetTop> createState() => _RatingSheetTopState();
}

/// ---------------- Review Model ----------------
class Review {
  final String userName;
  final String avatarPath;
  final String date;
  final String text;
  final double rating;
  final int reviewCount;

  Review({
    required this.userName,
    required this.avatarPath,
    required this.date,
    required this.text,
    required this.rating,
    required this.reviewCount,
  });
}

class _RatingSheetTopState extends State<RatingSheetTop> {
  // fraction of screen height the sheet currently uses (0.0 .. 1.0)
  double _sheetHeightFraction = 0.6; // start at 60%
  final double _minFraction = 0.4;
  final double _snapToFullThreshold = 0.85;
  String? _expandedReviewUser;

  // used to track a drag
  double _dragStartGlobalY = 0.0;
  double _dragStartFraction = 0.6;

  String _selectedFilter = 'Newest';
  final ScrollController _scrollController = ScrollController();

  // Sample reviews
  final List<Review> _reviews = [
    Review(
      userName: "Tharindu Nipun",
      avatarPath: "assets/Profile1.png",
      date: "1 day ago",
      text:
          "Amazing! The room is good than the picture. Thanks for amazing experience!hghghhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh",
      rating: 4.5,
      reviewCount: 19,
    ),
    Review(
      userName: "Kamal Perera",
      avatarPath: "assets/Profile3.png",
      date: "2 days ago",
      text:
          "Amazing! The room is good than the picture. Thanks for amazing experience!",
      rating: 4.5,
      reviewCount: 5,
    ),
    Review(
      userName: "Nidarshna",
      avatarPath: "assets/Profile4.png",
      date: "4 days ago",
      text:
          "Amazing! The room is good than the picture. Thanks for amazing experience!",
      rating: 3.5,
      reviewCount: 29,
    ),
    Review(
      userName: "Devindi Perera",
      avatarPath: "assets/Profile5.png",
      date: "6 days ago",
      text:
          "Amazing! The room is good than the picture. Thanks for amazing experience!",
      rating: 4.5,
      reviewCount: 5,
    ),
  ];

  bool get _isExpanded => _sheetHeightFraction >= 1.0 - 0.0001;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onHandleDragStart(DragStartDetails details) {
    _dragStartGlobalY = details.globalPosition.dy;
    _dragStartFraction = _sheetHeightFraction;
  }

  void _onHandleDragUpdate(DragUpdateDetails details, double screenHeight) {
    final double currentGlobalY = details.globalPosition.dy;
    final double delta = currentGlobalY - _dragStartGlobalY; // + if moving down
    final double newFraction = (_dragStartFraction + delta / screenHeight)
        .clamp(_minFraction, 1.0);
    setState(() {
      _sheetHeightFraction = newFraction;
    });
  }

  void _onHandleDragEnd(DragEndDetails details) {
    final v = details.primaryVelocity ?? 0.0;

    // Fast swipe up: dismiss immediately
    if (v < -700) {
      Navigator.of(context).pop();
      return;
    }

    // Fast swipe down: go full
    if (v > 700) {
      setState(() => _sheetHeightFraction = 1.0);
      return;
    }

    // Otherwise snap by position
    if (_sheetHeightFraction >= _snapToFullThreshold) {
      setState(() => _sheetHeightFraction = 1.0);
    } else {
      setState(() => _sheetHeightFraction = 0.6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black54,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                height: screenHeight * _sheetHeightFraction,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      _isExpanded
                          ? null
                          : const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 15),

                            if (_isExpanded) ...[
                              _buildHeader(),
                              const SizedBox(height: 16),
                            ],

                            _buildFilterButtons(),
                            const SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 2, child: _buildRatingSummary()),
                                const SizedBox(width: 20),
                                Expanded(
                                  flex: 3,
                                  child: _buildRatingBreakdown(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),

                            /// ✅ Extra content for logged-in users
                            if (widget.isLoggedIn)
                              _buildExtraContentForLoggedInUsers(),

                            /// 🔥 Reviews section scrollable
                            Expanded(
                              child: ListView.builder(
                                controller: _scrollController,
                                physics: const BouncingScrollPhysics(),
                                itemCount: _reviews.length,
                                itemBuilder: (context, index) {
                                  return _buildReviewCard(_reviews[index]);
                                },
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),

                    // Handle at bottom
                    if (!_isExpanded)
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onVerticalDragStart: _onHandleDragStart,
                        onVerticalDragUpdate:
                            (details) =>
                                _onHandleDragUpdate(details, screenHeight),
                        onVerticalDragEnd: _onHandleDragEnd,
                        child: _buildHandle(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- UI pieces ----------------

  Widget _buildFilterButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterButton('Newest'),
          const SizedBox(width: 10),
          _buildFilterButton('Highest'),
          const SizedBox(width: 10),
          _buildFilterButton('Lowest'),
          const SizedBox(width: 10),
          _buildFilterButton('Value for money'),
          const SizedBox(width: 10),
          _buildFilterButton('Cleanliness'),
          const SizedBox(width: 10),
          _buildFilterButton('Staff'),
          const SizedBox(width: 10),
          _buildFilterButton('Location'),
          const SizedBox(width: 10),
          _buildFilterButton('Facilities'),
          const SizedBox(width: 10),
          _buildFilterButton('Comfort'),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text) {
    bool isSelected = _selectedFilter == text;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedFilter = text;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF1A4D99) : Colors.white,
        foregroundColor: isSelected ? Colors.white : const Color(0xFF1A4D99),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: Color(0xFF1A4D99), width: 2),
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(text),
    );
  }

  Widget _buildRatingSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "4.8",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            return Icon(
              Icons.star_rounded,
              color: index == 4 ? const Color(0xFFE3E9ED) : Colors.amber,
              size: 24,
            );
          }),
        ),

        const SizedBox(height: 5),
        const Text(
          "Based on 532 review",
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildRatingBreakdown() {
    final Map<int, double> ratings = {1: 0.1, 2: 0.15, 3: 0.25, 4: 0.4, 5: 0.6};
    return Padding(
      padding: const EdgeInsets.only(left: 45.0),
      child: Column(
        children: List.generate(5, (index) {
          final star = 1 + index;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.5),
            child: Row(
              children: [
                Text(
                  '$star',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(width: 5),
                SizedBox(
                  width: 120,
                  child: LinearProgressIndicator(
                    value: ratings[star],
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue[800]!,
                    ),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    bool isExpanded = _expandedReviewUser == review.userName;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_expandedReviewUser == review.userName) {
            _expandedReviewUser = null; // collapse if already expanded
          } else {
            _expandedReviewUser = review.userName; // expand this review
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.only(top: 12.0, left: 8, right: 8, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage(review.avatarPath),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "${review.userName} (${review.reviewCount} Reviews)",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              softWrap: true,
                              maxLines: 2,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                review.rating.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        review.date,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// --- Review text
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal:
                    isExpanded
                        ? 1.0
                        : 50.0, // Adjust padding based on expansion
              ),
              child: Text(
                review.text,
                maxLines: isExpanded ? null : 2, // Expand/collapse
                overflow:
                    isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign:
                    isExpanded
                        ? TextAlign.left
                        : TextAlign.justify, // Left-align when expanded
              ),
            ),

            /// --- Extra details only if expanded
            if (isExpanded) ...[
              const SizedBox(height: 12),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTagContainer("Private Room"),
                    const SizedBox(width: 7),
                    _buildTagContainer("Clean"),
                    const SizedBox(width: 7),
                    _buildTagContainer("Great Location"),
                    const SizedBox(width: 7),
                    _buildTagContainer("Peaceful"),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.start, // Align images to the start
                    children: [
                      _buildReviewImage('assets/reviewImage1.png'),
                      const SizedBox(width: 8), // Spacing between images
                      _buildReviewImage('assets/reviewImage2.png'),
                      const SizedBox(width: 8),
                      _buildReviewImage('assets/reviewImage3.png'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Icon(Icons.favorite_border, color: Colors.black),
                  const SizedBox(width: 10),
                  Text(
                    "Press and hold to react",
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                  Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SvgPicture.asset(
                      'assets/icons/shareSquare.svg',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 130,
      height: 5,
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF6E6969),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundImage: AssetImage('assets/Profile2.png'),
        ),
        const SizedBox(width: 12),
        const Text(
          "Hostel First Mirissa",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  // Helper method to build each tag container
  Widget _buildTagContainer(String text) {
    return Container(
      height: 29,
      padding: const EdgeInsets.symmetric(horizontal: 16), // Adjustable padding
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Colors.grey[300],
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  // Helper method to build each image
  Widget _buildReviewImage(String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8), // Rounded corners for images
      child: Image.asset(
        imagePath,
        width: 95, // Fixed width for consistency
        height: 95, // Fixed height for consistency
        fit: BoxFit.cover, // Ensure image fits within bounds
        errorBuilder: (context, error, stackTrace) {
          return Container(width: 100, height: 100, color: Colors.grey[300]);
        },
      ),
    );
  }

  Widget _buildExtraContentForLoggedInUsers() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HostelReviewPage()),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(thickness: 2), // 🔹 First divider

          const SizedBox(height: 8),
          const Text(
            "Rate and Review",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // 🔹 Row with avatar and stars
          Row(
            children: [
              const CircleAvatar(
                radius: 17,
                backgroundImage: AssetImage(
                  "assets/profile6.png",
                ), // replace with actual path
              ),
              const SizedBox(width: 12),

              // Generate 5 star icons
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star, // outlined star by default
                    color: Color(0xFFE3E9ED),
                    size: 28,
                  );
                }),
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(thickness: 2), // 🔹 Second divider
        ],
      ),
    );
  }
}
