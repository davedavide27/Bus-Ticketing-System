import 'package:flutter/material.dart';
import 'package:senraise_printer/senraise_printer.dart';

class PrinterService {
  static final _senraisePrinterPlugin = SenraisePrinter();

  static Future<void> printReceipt({
    required BuildContext context,
    required String line,
    required String departureDate,
    required String departureTime,
    required String busNumber,
    required String licensePlate,
    required String openingOr,
    required String openingSaleDateTime,
  }) async {
    String receiptContent = '''
    
------------------------------
DEPARTURE SUCCESSFULLY OPENED
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
      await _senraisePrinterPlugin.setTextBold(true);
      await _senraisePrinterPlugin.setTextSize(24); // Adjust the text size as needed
      await _senraisePrinterPlugin.printText(receiptContent);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt printed successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to print receipt: $e')),
      );
    }
  }
}
