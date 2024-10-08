import 'package:flutter/material.dart';
import '../background.dart'; // Import the Background widget
import 'headcount_screen.dart'; // Import the HeadcountScreen
import 'select_stop_screen.dart'; // Import the SelectStopScreen
import '../settings.dart'; // Import the SettingsPage
import 'tickets_today.dart'; // Import the TicketsTodayScreen
import '../database_helper.dart'; // Import DatabaseHelper

class MenuScreen extends StatefulWidget {
  final void Function() onDepartureStart;
  final void Function() onDepartureClose;
  final bool departureStarted;
  final bool departureClosed;
  final String licensePlate;
  final void Function(String) onLicensePlateChanged;
  final List<String> routes;
  final void Function(List<String>) onRoutesChanged;

  const MenuScreen({
    required this.onDepartureStart,
    required this.onDepartureClose,
    required this.departureStarted,
    required this.departureClosed,
    required this.licensePlate,
    required this.onLicensePlateChanged,
    required this.routes,
    required this.onRoutesChanged,
    Key? key,
  }) : super(key: key);

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool _isDepartureOpen = false;

  @override
  void initState() {
    super.initState();
    _checkOpenDeparture();
  }

  Future<void> _checkOpenDeparture() async {
    final dbHelper = DatabaseHelper();
    final openDeparture = await dbHelper.getOpenDeparture();
    setState(() {
      _isDepartureOpen = openDeparture != null;
    });
  }

  Future<bool> _onWillPop() async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit?'),
          content: const Text('Are you sure you want to exit?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false to not exit
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true to exit
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    return result ?? false; // If result is null, return false
  }

  // Helper function to build a uniform button
  Widget _buildMenuButton(String text, VoidCallback onPressed) {
    return FractionallySizedBox(
      widthFactor: 0.4, // 50% of the screen width
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(vertical: 15),
        ),
        child: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('BUS MENU'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  SettingsPage.routeName,
                  arguments: {
                    'initialLicensePlate': widget.licensePlate,
                    'initialRoutes': widget.routes,
                  },
                );

                if (result is Map<String, dynamic>) {
                  final newLicensePlate = result['licensePlate'] as String? ?? widget.licensePlate;
                  final newRoutes = result['routes'] as List<String>? ?? widget.routes;

                  widget.onLicensePlateChanged(newLicensePlate);
                  widget.onRoutesChanged(newRoutes);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings updated')),
                  );
                }
              },
            ),
          ],
        ),
        body: Background(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _buildMenuButton('BUS TICKET', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SelectStopScreen()),
                        );
                      }),
                      SizedBox(height: 16),
                      _buildMenuButton('REPORTING TICKET', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HeadcountScreen()),
                        );
                      }),
                      SizedBox(height: 16),
                      _buildMenuButton('VIEW TICKETS TODAY', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TicketsTodayScreen()),
                        );
                      }),
                      if (widget.departureClosed)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Departure has been closed.',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: const Text(
                  'Created By: Dave Davide & Vince Carl Aratan',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
