import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database_helper.dart'; // Adjust the path as needed


class AllTicketsScreen extends StatefulWidget {
  @override
  _AllTicketsScreenState createState() => _AllTicketsScreenState();
}

class _AllTicketsScreenState extends State<AllTicketsScreen> {
  late Future<List<Map<String, dynamic>>> _ticketsFuture;
  List<Map<String, dynamic>> _allTickets = [];
  List<Map<String, dynamic>> _filteredTickets = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _ticketsFuture = _fetchAllTickets().then((tickets) {
      setState(() {
        _allTickets = tickets;
        _filteredTickets = tickets;
      });
      return tickets;
    });
  }

  Future<List<Map<String, dynamic>>> _fetchAllTickets() async {
    final dbHelper = DatabaseHelper();
    return await dbHelper.getAllTickets();
  }

  void _filterTickets(String query) {
    setState(() {
      _searchQuery = query;
      _filteredTickets = _allTickets
          .where((ticket) => (ticket['bus_or_number'] as String)
          .toLowerCase()
          .contains(query.toLowerCase()))
          .toList();
    });
  }

  String _formatDateTime(DateTime dateTime) {
    final dateFormat = DateFormat('yyyy-MM-dd hh:mm a'); // 12-hour format with AM/PM
    return dateFormat.format(dateTime);
  }

  TextStyle _ticketTitleStyle(BuildContext context) {
    return TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.bold,
      color: Colors.blueGrey[800],
    );
  }

  TextStyle _ticketSubtitleStyle(BuildContext context) {
    return TextStyle(
      fontSize: 16.0,
      color: Colors.black87,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100], // Light grey background
      appBar: AppBar(
        title: const Text('All Tickets'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Search by Ticket OR Number',
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                _filterTickets(query);
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _ticketsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No tickets available.'));
                }

                final tickets = _filteredTickets;

                return ListView.builder(
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    final issuedAt = DateTime.parse(ticket['issued_at']);
                    final isCancelled = ticket['is_cancelled'] == 1;

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        color: isCancelled ? Colors.grey[300] : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ticket NO: ${ticket['id']}',
                                style: _ticketTitleStyle(context),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'Starting Stop: ${ticket['starting_stop']}',
                                style: _ticketSubtitleStyle(context),
                              ),
                              Text(
                                'Destination Stop: ${ticket['destination_stop']}',
                                style: _ticketSubtitleStyle(context),
                              ),
                              Text(
                                'Fare: ₱${(ticket['fare'] as double).toStringAsFixed(2)}',
                                style: _ticketSubtitleStyle(context),
                              ),
                              Text(
                                'Discounted: ${ticket['is_discounted'] == 1 ? 'Yes' : 'No'}',
                                style: _ticketSubtitleStyle(context),
                              ),
                              Text(
                                'Ticket OR NO: ${ticket['bus_or_number']}',
                                style: _ticketSubtitleStyle(context),
                              ),
                              Text(
                                'Cancelled: ${isCancelled ? 'Yes' : 'No'}',
                                style: _ticketSubtitleStyle(context),
                              ),
                              Text(
                                'Issued At: ${_formatDateTime(issuedAt)}',
                                style: _ticketSubtitleStyle(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
