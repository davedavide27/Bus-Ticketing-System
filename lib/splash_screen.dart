import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import 'screens/menu_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _backgroundOpacity = 1.0;  // Opacity for background fade-out
  Color _textColor = Colors.white;  // Initial text color

  @override
  void initState() {
    super.initState();

    // Schedule background fade-out and text color change
    Timer(const Duration(seconds: 2), () {
      setState(() {
        _backgroundOpacity = 0.0;  // Fade the background out
        _textColor = Colors.orange;  // Change text color to orange
      });
    });

    // Navigate to the next screen after fade-out is complete
    Timer(const Duration(seconds: 4), () {  // Adjust the timing if needed
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MenuScreen(
            onDepartureStart: () {},
            onDepartureClose: () {},
            departureStarted: false,
            departureClosed: false,
            licensePlate: '',
            onLicensePlateChanged: (String license) {},
            routes: [],
            onRoutesChanged: (List<String> routes) {},
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedOpacity(
            opacity: _backgroundOpacity,
            duration: const Duration(milliseconds: 1900), // Fade duration for background
            child: Container(
              color: Colors.blueAccent,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LottieBuilder.asset(
                  "assets/lottie/Animation - 1723779223163.json",
                  height: 300,
                  width: 300,
                ),
                const SizedBox(height: 20),
                AnimatedDefaultTextStyle(
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                  duration: const Duration(milliseconds: 1900),  // Match text fade duration with background
                  child: const Text(
                    'TRANS-CO\n'
                        'A Bus Ticketing System',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
