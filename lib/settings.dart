import 'package:flutter/material.dart';
import 'database_helper.dart'; // Import your DatabaseHelper class

class SettingsPage extends StatefulWidget {
  static const String routeName = '/settings'; // Define route name

  final String initialLicensePlate;
  final ValueChanged<String> onLicensePlateChanged;
  final List<String> initialRoutes;
  final ValueChanged<List<String>> onRoutesChanged;

  const SettingsPage({
    super.key,
    required this.initialLicensePlate,
    required this.onLicensePlateChanged,
    required this.initialRoutes,
    required this.onRoutesChanged,
  });

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController licensePlateController = TextEditingController();
  final TextEditingController routeController = TextEditingController();
  List<String> routes = [];

  @override
  void initState() {
    super.initState();
    licensePlateController.text = widget.initialLicensePlate;
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

    // Save the license plate
    await dbHelper.insertLicensePlate(licensePlateController.text);

    // Clear existing routes and save new routes
    await dbHelper.clearRoutes(); // Ensure old routes are removed
    for (var route in routes) {
      await dbHelper.insertRoute(route); // Save each route individually
    }

    // Update the settings
    widget.onLicensePlateChanged(licensePlateController.text);
    widget.onRoutesChanged(routes);

    // Debug statement to confirm settings are saved
    print('Settings saved with license plate: ${licensePlateController.text}');

    Navigator.pop(context, {
      'licensePlate': licensePlateController.text,
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
    routeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
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
            Expanded(
              child: ListView.builder(
                itemCount: routes.length,
                itemBuilder: (context, index) {
                  final route = routes[index];
                  return ListTile(
                    title: Text(route),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteRoute(index),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _saveSettings,
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
