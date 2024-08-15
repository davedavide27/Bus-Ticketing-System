import 'package:flutter/material.dart';
import '../database_helper.dart'; // Adjust the path as needed

class ReportingTicketScreen extends StatefulWidget {
  final int headcount;

  const ReportingTicketScreen({Key? key, required this.headcount}) : super(key: key);

  @override
  _ReportingTicketScreenState createState() => _ReportingTicketScreenState();
}

class _ReportingTicketScreenState extends State<ReportingTicketScreen> {
  late Future<Map<String, dynamic>> _reportDataFuture;

  @override
  void initState() {
    super.initState();
    _reportDataFuture = _generateReport();
  }

  Future<Map<String, dynamic>> _generateReport() async {
    final dbHelper = DatabaseHelper();

    // Retrieve tickets for today
    final tickets = await dbHelper.getTicketsForToday();

    // Calculate line (starting stop) and checkpoint (last destination stop)
    String? line;
    String? checkpoint;
    int totalTickets = 0;
    int validTickets = 0;
    double totalFare = 0.0;

    if (tickets.isNotEmpty) {
      // Set line to the starting stop of the last ticket
      line = tickets.last['starting_stop'];
      checkpoint = tickets.last['destination_stop'];
      totalTickets = tickets.length;
      validTickets = tickets.where((ticket) => ticket['is_cancelled'] == 0).length;
      totalFare = tickets.fold(0.0, (sum, ticket) => sum + (ticket['fare'] as double));
    }

    // Calculate discrepancies
    int discrepancies = widget.headcount - validTickets;

    return {
      'line': line,
      'checkpoint': checkpoint,
      'totalTickets': totalTickets,
      'discrepancies': discrepancies,
      'validTickets': validTickets,
      'cancelledTickets': totalTickets - validTickets,
      'totalFare': totalFare,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporting Ticket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _reportDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No data available.'));
            }

            final reportData = snapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'SPECIFICATION OF SOLD TICKETS',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text('Line: ${reportData['line'] ?? 'N/A'}'),
                const SizedBox(height: 10),
                const Text('Passengers Summary', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Checkpoint: ${reportData['checkpoint'] ?? 'N/A'}'),
                Text('On-board Passengers: ${widget.headcount}'),
                const SizedBox(height: 10),
                const Divider(),
                Text('Headcount: ${widget.headcount} Passenger(s)'),
                Text('Discrepancy: ${reportData['discrepancies']} Passengers'),
                const SizedBox(height: 10),
                Text('Total Passengers: ${reportData['totalTickets']}'),
                Text('Cancelled Tickets: ${reportData['cancelledTickets']}'),
                Text('Total Valid Tickets: ${reportData['validTickets']}'),
                Text('Total Fare Collected: \₱${reportData['totalFare'].toStringAsFixed(2)}'),
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
            );
          },
        ),
      ),
    );
  }
}
