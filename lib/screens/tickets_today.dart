import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database_helper.dart';
import 'all_tickets.dart'; // Import the AllTicketsScreen

class TicketsTodayScreen extends StatefulWidget {
  @override
  _TicketsTodayScreenState createState() => _TicketsTodayScreenState();
}

class _TicketsTodayScreenState extends State<TicketsTodayScreen> {
  late Future<List<Map<String, dynamic>>> _ticketsFuture;
  List<Map<String, dynamic>> _allTickets = [];
  List<Map<String, dynamic>> _filteredTickets = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _ticketsFuture = _fetchTicketsForToday().then((tickets) {
      setState(() {
        _allTickets = tickets;
        _filteredTickets = tickets;
      });
      return tickets;
    });
  }

  Future<List<Map<String, dynamic>>> _fetchTicketsForToday() async {
    final dbHelper = DatabaseHelper();
    final allTickets = await dbHelper.getAllTickets();

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final todayTickets = allTickets.where((ticket) {
      final issuedAt = DateTime.parse(ticket['issued_at']);
      final issuedDate = DateFormat('yyyy-MM-dd').format(issuedAt);
      return issuedDate == today;
    }).toList();

    return todayTickets;
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

  Future<void> _showCancelTicketDialog(int ticketId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Ticket'),
          content: const Text('Are you sure you want to cancel this ticket?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () async {
                final dbHelper = DatabaseHelper();
                await dbHelper.updateTicketCancellation(ticketId, true);
                final updatedTickets = await _fetchTicketsForToday();
                setState(() {
                  _allTickets = updatedTickets;
                  _filterTickets(_searchQuery);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tickets Issued Today'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.list,
              size: 35.0, // Adjust the size as needed
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AllTicketsScreen()),
              );
            },
            tooltip: 'View All Tickets',
          ),
        ],
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
                  return const Center(child: Text('No tickets issued today.'));
                }

                final tickets = _filteredTickets;

                return ListView.builder(
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    final issuedAt = DateTime.parse(ticket['issued_at']);
                    final isCancelled = ticket['is_cancelled'] == 1;

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        color: isCancelled ? Colors.grey[300] : Colors.white,
                        child: InkWell(
                          onTap: isCancelled
                              ? null
                              : () {
                            _showCancelTicketDialog(ticket['id']);
                          },
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
