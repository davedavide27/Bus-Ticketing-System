import 'package:flutter/material.dart';
import 'reporting_ticket_screen.dart';

class HeadcountScreen extends StatefulWidget {
  const HeadcountScreen({Key? key}) : super(key: key);

  @override
  _HeadcountScreenState createState() => _HeadcountScreenState();
}

class _HeadcountScreenState extends State<HeadcountScreen> {
  final TextEditingController _headcountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Headcount'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _headcountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Headcount',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                int headcount = int.tryParse(_headcountController.text) ?? 0;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportingTicketScreen(headcount: headcount),
                  ),
                );
              },
              child: const Text('Generate Report'),
            ),
          ],
        ),
      ),
    );
  }
}
