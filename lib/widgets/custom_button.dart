import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the width of the screen
    final double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth * 0.5,  // Set the width to 50% of the screen width
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 18),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,  // Standard font size
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
