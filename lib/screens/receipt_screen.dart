import 'package:flutter/material.dart';
import 'package:senraise_printer/senraise_printer.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting

class ReceiptScreen extends StatelessWidget {
  final String startingStop;
  final String destinationStop;
  final double fare;
  final bool isDiscounted;

  const ReceiptScreen({
    Key? key,
    required this.startingStop,
    required this.destinationStop,
    required this.fare,
    this.isDiscounted = false,
  }) : super(key: key);

  Future<void> printReceipt(BuildContext context) async {
    final _senraisePrinterPlugin = SenraisePrinter();

    // Get current date and time
    final currentDateTime = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(currentDateTime);
    final formattedTime = DateFormat('hh:mm a').format(currentDateTime); // AM/PM format

    // Construct the receipt content with date and time
    String receiptContent = '''
    
    
------------------------------
BUS FARE RECEIPT
------------------------------
Starting Stop: $startingStop
Destination Stop: $destinationStop
Fare Type: ${isDiscounted ? 'Discounted' : 'Regular'}
Total Fare: ₱${fare.toStringAsFixed(2)}

------------------------------
Date and Time Issued:
$formattedDate | $formattedTime
------------------------------



    ''';

    try {
      await _senraisePrinterPlugin.setTextBold(true);
      await _senraisePrinterPlugin.setTextSize(24); // Adjust text size as needed
      await _senraisePrinterPlugin.printText(receiptContent);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt printed successfully')),
      );

      // Exit the screen after printing
      Navigator.of(context).pop();
    } catch (e) {
      // Show error message if printing fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to print receipt: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Starting Stop: $startingStop',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Destination Stop: $destinationStop',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Fare Type: ${isDiscounted ? 'Discounted' : 'Regular'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Fare: ₱${fare.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () => printReceipt(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                child: const Text('Print Receipt'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
