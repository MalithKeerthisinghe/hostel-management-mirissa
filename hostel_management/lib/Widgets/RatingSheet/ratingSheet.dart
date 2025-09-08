import 'package:flutter/material.dart';

class RatingSheetTop extends StatefulWidget {
  const RatingSheetTop({super.key});

  static void show(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder:
            (context, animation, secondaryAnimation) => const RatingSheetTop(),
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
          "Amazing! The room is good than the picture. Thanks for amazing experience!",
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
                            const SizedBox(height: 10),

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
                            const SizedBox(height: 20),

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
              index < 4 ? Icons.star_rounded : Icons.star_border_rounded,
              color: Colors.amber,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.only(top: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                            softWrap: true, // Allow text to wrap
                            maxLines: 2, // Optional: Limit to 2 lines
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
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 50.0,
              vertical: 10.0,
            ),
            child: Text(
              review.text,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
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
}
