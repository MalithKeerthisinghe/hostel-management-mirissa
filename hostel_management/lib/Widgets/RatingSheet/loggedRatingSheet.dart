import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HostelReviewPage extends StatefulWidget {
  const HostelReviewPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HostelReviewPageState createState() => _HostelReviewPageState();
}

class _HostelReviewPageState extends State<HostelReviewPage> {
  // Mock data for ratings
  final List<double> ratings = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
  final List<String> ratingCategories = [
    'Value for money',
    'Cleanliness',
    'Staff',
    'Location',
    'Facilities',
    'Comfort',
  ];
  final List<String> ratingIconPaths = [
    'assets/icons/money.svg',
    'assets/icons/cleanliness.svg',
    'assets/icons/staff.svg',
    'assets/icons/location.svg',
    'assets/icons/facilities.svg',
    'assets/icons/comfort.svg',
  ];

  String? selectedTripType;
  String? selectedTravelCompanion;

  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30), // optional top padding
          _buildHeader(), // 🔹 Header at top
          const SizedBox(height: 25),

          // 🔹 Rating summary + breakdown row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildRatingSummary()),
                const SizedBox(width: 20),
                Expanded(flex: 3, child: _buildRatingBreakdown()),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildExtraContentForLoggedInUsers(),
          ),

          // 🔹 Scrollable content below
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildRatingsSection(),
                    const SizedBox(height: 24),

                    Material(
                      color:
                          Theme.of(
                            context,
                          ).scaffoldBackgroundColor, // same as page
                      borderRadius: BorderRadius.circular(12.0),
                      elevation: 1, // 🔹 shadow/elevation
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildReviewTextField(),
                            const SizedBox(height: 16),
                            _buildUploadButton(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    _buildTripTypeSection(),
                    const SizedBox(height: 16),
                    _buildTravelCompanionSection(),
                    const SizedBox(height: 45),
                    _buildPostReviewButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingsSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFF3F4F6), width: 2.0),
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: const EdgeInsets.all(12.0), // optional padding inside container
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // 🔹 left-align title
        children: [
          const SizedBox(height: 15),
          const Text(
            "Rate your experience", // 🔹 your title
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12), // space between title and rows
          // 🔹 your original rating rows untouched
          ...List.generate(ratingCategories.length, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    ratingIconPaths[index], // path to your SVG
                    width: 27,
                    height: 27,
                    color: Colors.black, // optional
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      ratingCategories[index],
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // ⭐ Use Wrap for stars with spacing
                  Wrap(
                    alignment: WrapAlignment.start,
                    spacing: -25.0, // controls gap between stars
                    children: List.generate(5, (starIndex) {
                      return IconButton(
                        onPressed: () {
                          setState(() {
                            ratings[index] = starIndex + 1.0;
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          Icons.star_rounded, // always use the same icon shape
                          color:
                              starIndex < ratings[index]
                                  ? Colors
                                      .amber // ⭐ amber when clicked
                                  : const Color(
                                    0xFFE3E9ED,
                                  ), // 🔹 light grey otherwise
                        ),
                      );
                    }),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReviewTextField() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: const TextField(
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Tell others about your experience',
            hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SizedBox(
        width: 300,
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: SvgPicture.asset(
            'assets/icons/camera.svg',
            width: 25,
            height: 25,
            // ignore: deprecated_member_use
            color: Color(
              0xFF00358D,
            ), // optional, remove if SVG already has color
          ),
          label: const Text('Upload photos and videos'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE5E7EB), // 🔹 background color
            foregroundColor: Colors.black, // 🔹 text/icon color
            elevation: 0, // 🔹 flat look, no shadow
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildTripTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What kind of trip was it?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children:
              ['Business', 'Holiday'].map((type) {
                final isSelected = selectedTripType == type;
                return ChoiceChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      selectedTripType = selected ? type : null;
                    });
                  },
                  selectedColor: Colors.blue.withOpacity(0.1),
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100.0),
                    side: BorderSide(
                      color: isSelected ? Colors.blue : Color(0xFFE5E7EB),
                      width: 2,
                    ),
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.blue : Colors.black87,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildTravelCompanionSection() {
    final companions = ['Solo', 'Couple', 'Family', 'Friends'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Who did you travel with?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0, // Horizontal space between buttons
          runSpacing: 8.0, // Vertical space between rows
          alignment: WrapAlignment.start,
          children:
              companions.map((companion) {
                final isSelected = selectedTravelCompanion == companion;
                return Container(
                  width: 150.0,
                  height: 50, // Fixed width for uniform size
                  child: ChoiceChip(
                    label: Center(
                      child: Text(
                        companion,
                        style: TextStyle(
                          color: isSelected ? Colors.blue : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedTravelCompanion = selected ? companion : null;
                      });
                    },
                    // ignore: deprecated_member_use
                    selectedColor: Colors.blue.withOpacity(0.1),
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: BorderSide(
                        color: isSelected ? Colors.blue : Color(0xFFE5E7EB),
                        width: 2,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 0,
                    ), // Remove extra padding
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildPostReviewButton() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF00B1D6), // Cyan at 0%
              Color(0xFF00358D), // Dark blue at 100%
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ElevatedButton(
          onPressed: () {
            // Handle post review logic
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent, // Transparent to show gradient
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            shadowColor: Colors.transparent, // Remove default shadow
          ),
          child: const Text(
            'Post Review',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
        ),
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

  Widget _buildExtraContentForLoggedInUsers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }
}
