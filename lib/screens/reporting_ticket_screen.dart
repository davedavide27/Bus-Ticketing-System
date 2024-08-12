import 'package:flutter/material.dart';

class ReportingTicketScreen extends StatelessWidget {
  final int headcount;

  const ReportingTicketScreen({Key? key, required this.headcount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporting Ticket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'SPECIFICATION OF SOLD TICKETS',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // List of details
            const Text('Line: 134 / Bancasi-Dumagalan to Ampayon Rotunda'),
            const SizedBox(height: 10),
            const Text('Passengers Summary', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('No tickets found'),
            const SizedBox(height: 10),
            const Text('Alighted Passengers: 0'),
            const Text('Checkpoint: 0 Bancasi-Dumagalan Crossing'),
            const Text('On-board Passengers: 0'),
            const SizedBox(height: 10),
            const Divider(),
            // Ticket details
            Text('Headcount: $headcount Passenger(s)'),
            const Text('Discrepancy: 0 Passengers'),
            const SizedBox(height: 10),
            const Text('Total Passengers: 0'),
            const Text('Cancelled Tickets: 0'),
            const Text('Total Valid Tickets: 0'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Implement printing logic here
                  },
                  child: const Text('Print'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
