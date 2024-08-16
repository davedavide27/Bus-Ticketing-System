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

  @override
  void initState() {
    super.initState();

    // Schedule background fade-out
    Timer(Duration(seconds: 2), () {
      setState(() {
        _backgroundOpacity = 0.0;  // Fade the background out
      });
    });

    // Navigate to the next screen after fade-out is complete
    Timer(Duration(seconds: 4), () {  // Adjust the timing if needed
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
            duration: Duration(milliseconds: 1900), // Fade duration for background
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
                const Text(
                  'BALTRANSCO\n'
                      'A Bus Ticketing System',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
