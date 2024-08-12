import 'package:flutter/material.dart';
import 'bus_ticket_screen.dart'; // Import the BusTicketScreen
import '../database_helper.dart'; // Import DatabaseHelper
import '../printer_service.dart'; // Import PrinterService
import '../or_number_service.dart'; // Import ORNumberService

class SelectStopScreen extends StatefulWidget {
  const SelectStopScreen({Key? key}) : super(key: key);

  @override
  _SelectStopScreenState createState() => _SelectStopScreenState();
}

class _SelectStopScreenState extends State<SelectStopScreen> {
  List<String> stops = [];
  String? selectedStop;
  bool reverseOrder = false;
  String licensePlate = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dbHelper = DatabaseHelper();

    // Fetch license plate and routes from the database
    final plate = await dbHelper.getLicensePlate();
    final routeList = await dbHelper.getRoutes();

    setState(() {
      licensePlate = plate ?? '';
      stops = routeList;
    });
  }

  void _printReceipt() async {
    if (selectedStop != null) {
      final openingOrNumber = await ORNumberService.getNextORNumber();
      final currentDateTime = DateTime.now();
      final openingSaleDateTime = '${currentDateTime.toLocal().toString().split(' ')[0]} ${TimeOfDay.now().format(context)}';

      PrinterService.printReceipt(
        context: context,
        line: selectedStop!,
        departureDate: currentDateTime.toLocal().toString().split(' ')[0],
        departureTime: TimeOfDay.now().format(context),
        busNumber: '1234', // Replace with actual bus number if needed
        licensePlate: licensePlate,
        openingOr: openingOrNumber,
        openingSaleDateTime: openingSaleDateTime,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Starting Stop'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              hint: const Text('Select Starting Stop'),
              value: selectedStop,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              style: const TextStyle(color: Colors.black),
              underline: Container(
                height: 2,
                color: Colors.orange,
              ),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedStop = newValue;
                    reverseOrder = newValue == 'Ampayon Rotunda KM 16';
                  });
                }
              },
              items: stops.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectedStop != null
                  ? () {
                _printReceipt(); // Print the receipt before navigating
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BusTicketScreen(
                      startingStop: selectedStop!,
                      reverseOrder: reverseOrder,
                    ),
                  ),
                );
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                child: Text('CONTINUE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
