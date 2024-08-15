import 'package:flutter/material.dart';
import 'printer_service.dart'; // Import PrinterService
import 'or_number_service.dart'; // Import ORNumberService

class DepartureSetupPage extends StatefulWidget {
  static const routeName = '/departureSetup';

  final void Function() onDepartureClose;
  final bool departureStarted;
  final bool departureClosed;
  final String licensePlate;
  final List<String> routes;

  const DepartureSetupPage({
    required this.onDepartureClose,
    required this.departureStarted,
    required this.departureClosed,
    required this.licensePlate,
    required this.routes,
    Key? key,
  }) : super(key: key);

  @override
  _DepartureSetupPageState createState() => _DepartureSetupPageState();
}

class _DepartureSetupPageState extends State<DepartureSetupPage> {
  String? _selectedRoute;
  DateTime _departureDate = DateTime.now();
  TimeOfDay _departureTime = TimeOfDay.now();
  String _busNumber = '';
  Future<void> _openDeparture() async {
    if (_selectedRoute == null || _busNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the fields.')),
      );
      return;
    }

    final openingOrNumber = await ORNumberService.getNextORNumber();
    final openingSaleDateTime = '${_departureDate.toLocal().toString().split(' ')[0]} ${_departureTime.format(context)}';

    PrinterService.printReceipt(
      context: context,
      line: _selectedRoute!,
      departureDate: _departureDate.toLocal().toString().split(' ')[0],
      departureTime: _departureTime.format(context),
      busNumber: _busNumber,
      licensePlate: widget.licensePlate,
      openingOr: openingOrNumber,
      openingSaleDateTime: openingSaleDateTime,
    );

    widget.onDepartureClose();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Departure Setup'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedRoute,
              hint: const Text('Select Route'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRoute = newValue;
                });
              },
              items: widget.routes.map<DropdownMenuItem<String>>((String route) {
                return DropdownMenuItem<String>(
                  value: route,
                  child: Text(route),
                );
              }).toList(),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Bus Number'),
              onChanged: (value) {
                _busNumber = value;
              },
            ),
            ElevatedButton(
              onPressed: _openDeparture,
              child: const Text('Open Departure'),
            ),
          ],
        ),
      ),
    );
  }
}
