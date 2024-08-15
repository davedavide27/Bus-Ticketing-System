import 'package:flutter/material.dart';
import '../background.dart';
import 'headcount_screen.dart';
import 'select_stop_screen.dart';
import '../settings.dart';
import 'tickets_today.dart';
import '../database_helper.dart';
import '../widgets/custom_button.dart'; // Import the custom button

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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CustomButton(
                  text: 'BUS TICKET',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SelectStopScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'REPORTING TICKET',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HeadcountScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'VIEW TICKETS TODAY',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TicketsTodayScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
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
      ),
    );
  }
}