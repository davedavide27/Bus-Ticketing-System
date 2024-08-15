import 'package:flutter/material.dart';
import 'package:senraise_printer/senraise_printer.dart';

class PrinterService {
  static final _senraisePrinterPlugin = SenraisePrinter();

  // Method to print a departure close receipt
  static Future<void> printDepartureCloseReceipt({
    required BuildContext context,
    required String line,
    required String departureDate,
    required String departureTime,
    required String busNumber,
    required String licensePlate,
    required String openingOr,
    required String openingSaleDateTime,
  }) async {
    // Construct the receipt content
    String receiptContent = '''
------------------------------
DEPARTURE CLOSE RECEIPT
------------------------------
Line: $line
Departure date: $departureDate
Departure time: $departureTime
Bus number: $busNumber
License Plate: $licensePlate
Opening OR: $openingOr
------------------------------
Opening sale date and time: 
      $openingSaleDateTime
------------------------------



    ''';

    try {
      // Set text styles
      await _senraisePrinterPlugin.setTextBold(true);
      await _senraisePrinterPlugin.setTextSize(24); // Adjust text size as needed

      // Print the receipt content
      await _senraisePrinterPlugin.printText(receiptContent);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt printed successfully')),
      );
    } catch (e) {
      // Show error message if printing fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to print receipt: $e')),
      );
    }
  }
}
