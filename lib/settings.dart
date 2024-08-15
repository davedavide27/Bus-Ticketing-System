import 'package:flutter/material.dart';
import 'database_helper.dart'; // Import your DatabaseHelper class

class SettingsPage extends StatefulWidget {
  static const String routeName = '/settings'; // Define route name

  final String initialLicensePlate;
  final String initialBusNumber; // Add initialBusNumber
  final ValueChanged<String> onLicensePlateChanged;
  final ValueChanged<String> onBusNumberChanged; // Add onBusNumberChanged
  final List<String> initialRoutes;
  final ValueChanged<List<String>> onRoutesChanged;

  const SettingsPage({
    super.key,
    required this.initialLicensePlate,
    required this.onLicensePlateChanged,
    required this.initialBusNumber, // Add this line
    required this.onBusNumberChanged, // Add this line
    required this.initialRoutes,
    required this.onRoutesChanged,
  });

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController licensePlateController = TextEditingController();
  final TextEditingController busNumberController = TextEditingController(); // Add Bus Number controller
  final TextEditingController routeController = TextEditingController();
  List<String> routes = [];

  @override
  void initState() {
    super.initState();
    licensePlateController.text = widget.initialLicensePlate;
    busNumberController.text = widget.initialBusNumber; // Initialize Bus Number
    routes = List.from(widget.initialRoutes); // Ensure the list is a copy
  }

  void _addRoute() {
    final route = routeController.text.trim();
    if (route.isNotEmpty && !routes.contains(route)) {
      setState(() {
        routes.add(route);
        routeController.clear();
      });
    }
  }

  Future<void> _saveSettings() async {
    final dbHelper = DatabaseHelper();

    // Debug statements to check values
    print('Saving license plate: ${licensePlateController.text}');
    print('Saving bus number: ${busNumberController.text}'); // Debug for Bus Number

    // Save the license plate and bus number
    await dbHelper.insertLicensePlate(licensePlateController.text);
    await dbHelper.insertBusNumber(busNumberController.text); // Save the Bus Number

    // Clear existing routes and save new routes
    await dbHelper.clearRoutes(); // Ensure old routes are removed
    for (var route in routes) {
      await dbHelper.insertRoute(route); // Save each route individually
    }

    // Update the settings
    widget.onLicensePlateChanged(licensePlateController.text);
    widget.onBusNumberChanged(busNumberController.text); // Update Bus Number
    widget.onRoutesChanged(routes);

    // Debug statement to confirm settings are saved
    print('Settings saved with license plate: ${licensePlateController.text}');
    print('Settings saved with bus number: ${busNumberController.text}'); // Debug for Bus Number

    Navigator.pop(context, {
      'licensePlate': licensePlateController.text,
      'busNumber': busNumberController.text, // Add Bus Number to pop result
      'routes': routes,
    });
  }

  void _deleteRoute(int index) async {
    final route = routes[index];
    setState(() {
      routes.removeAt(index);
    });

    final dbHelper = DatabaseHelper();
    await dbHelper.deleteRoute(route); // Remove route from database
  }

  @override
  void dispose() {
    licensePlateController.dispose();
    busNumberController.dispose(); // Dispose Bus Number controller
    routeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.save,
              size: 30.0, // Adjust the size as needed
            ),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: licensePlateController,
                decoration: const InputDecoration(
                  labelText: 'License Plate',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: busNumberController,
                decoration: const InputDecoration(
                  labelText: 'Bus Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: routeController,
                decoration: const InputDecoration(
                  labelText: 'Add Route',
                  border: OutlineInputBorder(),
                ),
              ),
              ElevatedButton(
                onPressed: _addRoute,
                child: const Text('Add Route'),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true, // Use shrinkWrap to make the ListView occupy only as much space as its children need
                physics: const NeverScrollableScrollPhysics(), // Disable scrolling for the ListView
                itemCount: routes.length,
                itemBuilder: (context, index) {
                  final route = routes[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          route,
                          style: const TextStyle(fontSize: 16.0),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteRoute(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
