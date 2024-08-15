import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<void> handleDepartureClose(
    BuildContext context,
    String selectedRoute,
    TextEditingController departureTimeController,
    TextEditingController licensePlateController,
    ) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Close Departure'),
      content: const Text('Close departure and print receipt?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Yes'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('No'),
        ),
      ],
    ),
  );

  if (result == true) {
    await _printClosingReceipt(
      context,
      selectedRoute,
      departureTimeController,
      licensePlateController,
    );
  }
}

Future<void> _printClosingReceipt(
    BuildContext context,
    String selectedRoute,
    TextEditingController departureTimeController,
    TextEditingController licensePlateController,
    ) async {
  final departureDateTime = departureTimeController.text;

  // Validate departure time format
  if (!RegExp(r'^\d{2}/\d{2}/\d{4} \| \d{2}:\d{2} (AM|PM)$').hasMatch(departureDateTime)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid departure time format. Use MM/DD/YYYY | HH:MM AM/PM')),
    );
    return;
  }

  final departureDate = departureDateTime.split(' | ')[0];
  final departureTime = departureDateTime.split(' | ')[1];

  try {
    // Create directory if it doesn't exist
    final directory = Directory('/storage/emulated/0/departure_receipts');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    // Generate file path and write receipt
    final filePath = '${directory.path}/closing_receipt_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.txt';
    final file = File(filePath);

    await file.writeAsString(
      '''
-------------------------------------------
DEPARTURE SUCCESSFULLY CLOSED\n\n
Line: $selectedRoute\n
Departure Date: $departureDate\n
Departure Time: $departureTime\n
Bus Number: BUS 018\n
License Plate: ${licensePlateController.text}\n
Closing OR: 026376\n
Closing Sale DateTime: 
${DateFormat('MM/dd/yyyy HH:mm:ss').format(DateTime.now())}
--------------------------------------------
      ''',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Closing receipt saved to $filePath')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to print closing receipt: $e')),
    );
  }
}

