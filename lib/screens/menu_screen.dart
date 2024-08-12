import 'package:flutter/material.dart';
import 'headcount_screen.dart';     // Import the HeadcountScreen
import 'select_stop_screen.dart';   // Import the SelectStopScreen
import '../settings.dart';      // Import the SettingsPage

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

              // Check if result is a Map and contains necessary data
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SelectStopScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                child: Text('BUS TICKET'),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HeadcountScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                child: Text('REPORTING TICKET'),
              ),
            ),
            const SizedBox(height: 20),
            if (widget.departureStarted && !widget.departureClosed)
              ElevatedButton(
                onPressed: widget.onDepartureClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  child: Text('CLOSE DEPARTURE'),
                ),
              ),
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
    );
  }
}
