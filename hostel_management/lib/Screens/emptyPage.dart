import 'package:flutter/material.dart';
import '../Widgets/RatingSheet/ratingSheet.dart';

class EmptyPage extends StatelessWidget {
  const EmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400],
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            RatingSheetTop.show(context);
          },
          child: const Text("Rating Sheet (Top)"),
        ),
      ),
    );
  }
}
