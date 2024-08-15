import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final Widget child;

  const Background({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Position the logo 10 pixels above the center
        Positioned(
          top: MediaQuery.of(context).size.height / 2 - 280,
          left: 0,
          right: 0,
          child: Center(
            child: Opacity(
              opacity: 0.4,
              child: Image.asset(
                'assets/images/BALTRANSCO.png',
                fit: BoxFit.contain,
                width: MediaQuery.of(context).size.width * 0.9, // 70% of screen width
              ),
            ),
          ),
        ),
        // Foreground content
        child,
      ],
    );
  }
}
