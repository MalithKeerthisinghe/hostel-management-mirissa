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
          const begin = Offset(0.0, -1.0); // Start from the top
          const end = Offset.zero; // End at the original position
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
  // ignore: library_private_types_in_public_api
  _RatingSheetTopState createState() => _RatingSheetTopState();
}

class _RatingSheetTopState extends State<RatingSheetTop> {
  // We'll manage the selected filter here
  String _selectedFilter = 'Newest';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54, // Semi-transparent background
      body: GestureDetector(
        // Allow tapping outside to dismiss
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Column(
          children: [
            // Use a GestureDetector here to prevent dismissal when interacting with the sheet itself
            GestureDetector(
              onTap: () {
                // Do nothing, just to stop the parent GestureDetector from firing
              },
              child: Container(
                // The height is now dynamic, covering the content below the safe area
                // Let's make it a fixed height for the example to match the image,
                // but usually, you'd use a flexible approach with ListView.
                height:
                    MediaQuery.of(context).size.height *
                    0.6, // Adjusted height to fit content
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Handle (the small gray bar at the bottom of the container)
                      Expanded(
                        child: SingleChildScrollView(
                          // Use SingleChildScrollView for scrollable content
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Toggle Buttons
                              _buildFilterButtons(),
                              const SizedBox(height: 20),

                              // Rating Summary and Breakdown
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: _buildRatingSummary(),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    flex: 3,
                                    child: _buildRatingBreakdown(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Individual Review
                              _buildReviewCard(),
                              const SizedBox(
                                height: 20,
                              ), // Add spacing for more reviews if needed
                            ],
                          ),
                        ),
                      ),
                      _buildHandle(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
        backgroundColor: isSelected ? Color(0xFF1A4D99) : Colors.white,
        foregroundColor: isSelected ? Colors.white : Color(0xFF1A4D99),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(color: Color(0xFF1A4D99), width: 2),
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(text),
    );
  }

  Widget _buildRatingSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // left-align everything
      children: [
        const Text(
          "4.8",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        // Align stars exactly to the left of 4.8
        Row(
          mainAxisSize: MainAxisSize.min, // only take needed width
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
                  width: 120, // <- Set your desired length here
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

  Widget _buildReviewCard() {
    return Container(
      padding: const EdgeInsets.only(top: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage(
                  'assets/Profile1.png', // Path to your asset image
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            "Tharindu Nipun (19 Reviews)",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const SizedBox(width: 20),
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 2),
                        const Text(
                          "4.5",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Text(
                      "1 day ago",
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
              "Amazing! The room is good than the picture.Thanks for amazing experience!",
              style: TextStyle(fontSize: 12, color: Colors.grey),
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
        color: Color(0xFF6E6969),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
