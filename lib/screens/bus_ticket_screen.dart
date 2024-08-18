import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Import for showing notifications
import '../animated_overlay.dart'; // Import the new animation file
import 'receipt_screen.dart'; // Adjust the path based on your project structure
import '../database_helper.dart'; // Import your database helper class

class BusTicketScreen extends StatefulWidget {
  final String startingStop;
  final bool reverseOrder;

  const BusTicketScreen({
    Key? key,
    required this.startingStop,
    this.reverseOrder = false,
  }) : super(key: key);

  @override
  _BusTicketScreenState createState() => _BusTicketScreenState();
}

class _BusTicketScreenState extends State<BusTicketScreen> with SingleTickerProviderStateMixin {
  final databaseHelper = DatabaseHelper();
  List<String> allStops = [];
  List<String> availableStops = [];
  String? selectedStop;
  String? selectedCard;

  double regularFare = 0.0;
  double discountedFare = 0.0;
  bool isReversed = false;
  bool showOverlay = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _loadSelectedStopFromDatabase();
    _loadRoutesFromDatabase();
  }

  Future<void> _loadRoutesFromDatabase() async {
    try {
      final routes = await databaseHelper.getRoutes();
      setState(() {
        allStops = routes;

        if (widget.reverseOrder || isReversed) {
          allStops = allStops.reversed.toList();
        }

        // Update selected stop and available stops
        if (widget.reverseOrder || isReversed) {
          selectedStop = allStops.firstWhere(
                (stop) => stop == selectedStop,
            orElse: () => allStops.first,
          );
        }

        _updateAvailableStops();
      });
    } catch (e) {
      print('Error loading routes: $e');
    }
  }

  Future<void> _loadSelectedStopFromDatabase() async {
    final stop = await databaseHelper.getSelectedStop();
    setState(() {
      selectedStop = stop ?? widget.startingStop;
      _updateAvailableStops();
    });
  }

  void _storeSelectedStop() async {
    if (selectedStop != null) {
      await databaseHelper.storeSelectedStop(selectedStop!);
    }
  }

  void _updateAvailableStops() {
    setState(() {
      final selectedIndex = allStops.indexOf(selectedStop ?? '');
      if (selectedIndex != -1) {
        availableStops = allStops.sublist(selectedIndex + 1);
      } else {
        availableStops = [];
      }
    });
  }

  void _updateSelectedStop(String newStop) {
    setState(() {
      selectedStop = newStop;
      _updateAvailableStops();
      _storeSelectedStop(); // Save selected stop to database
    });
  }

  void _toggleReverseOrder() {
    setState(() {
      isReversed = !isReversed;
      allStops = allStops.reversed.toList();
      selectedStop = allStops.firstWhere(
            (stop) => stop == selectedStop,
        orElse: () => allStops.first,
      );
      _updateAvailableStops();
    });

    _animationController.forward().then((_) {
      setState(() {
        showOverlay = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        _animationController.reverse().then((_) {
          setState(() {
            showOverlay = false;
          });
        });
      });
    });

    Fluttertoast.showToast(
      msg: isReversed ? "Route is reversed" : "Route is in original order",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
    );
  }

  void _moveToNextStop() {
    final currentIndex = allStops.indexOf(selectedStop ?? '');
    if (currentIndex < allStops.length - 1) {
      _updateSelectedStop(allStops[currentIndex + 1]);
    }
  }

  void _moveToPreviousStop() {
    final currentIndex = allStops.indexOf(selectedStop ?? '');
    if (currentIndex > 0) {
      _updateSelectedStop(allStops[currentIndex - 1]);
    }
  }

  void _onCardTapped(String stop) {
    setState(() {
      selectedCard = stop;
      _calculateFare();
    });
  }

  void _calculateFare() {
    final startKm = selectedStop?.split('KM ').last;
    final destinationKm = selectedCard?.split('KM ').last;

    if (startKm != null && destinationKm != null) {
      final startKmNumber = int.tryParse(startKm) ?? 0;
      final destinationKmNumber = int.tryParse(destinationKm) ?? 0;
      final distance = (isReversed
          ? startKmNumber - destinationKmNumber
          : destinationKmNumber - startKmNumber)
          .abs();

      if (distance > 0) {
        const baseFare = 15.0;
        final additionalFare = (distance > 4) ? (distance - 4) * 2.25 : 0.0;
        setState(() {
          regularFare = baseFare + additionalFare;
          discountedFare = regularFare * 0.8; // Apply 20% discount
        });
      } else {
        setState(() {
          regularFare = 0.0;
          discountedFare = 0.0;
        });
      }
    }
  }

  void _showReceipt(bool isDiscounted) async {
    final busOrNumber = await ORNumberService.getNextORNumber();

    await _insertTicket(isDiscounted, busOrNumber);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptScreen(
          startingStop: selectedStop ?? widget.startingStop, // Use selectedStop
          destinationStop: selectedCard ?? '',
          fare: isDiscounted ? discountedFare : regularFare,
          isDiscounted: isDiscounted,
          busOrNumber: busOrNumber,
        ),
      ),
    );
  }

  Future<void> _insertTicket(bool isDiscounted, String busOrNumber) async {
    final now = DateTime.now();

    await databaseHelper.insertTicket(
      issuedAt: now,
      startingStop: selectedStop ?? widget.startingStop, // Use selectedStop
      destinationStop: selectedCard ?? '',
      fare: isDiscounted ? discountedFare : regularFare,
      isDiscounted: isDiscounted,
      busOrNumber: busOrNumber,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Ticket Menu'),
        centerTitle: true,
        actions: [
          IconButton(
            iconSize: 40, // Adjust the size of the button
            onPressed: _toggleReverseOrder,
            icon: const Icon(Icons.swap_vert),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: _moveToPreviousStop,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        minimumSize: const Size(100, 40), // Adjust the size of the button
                      ),
                      child: const Text('PREV'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        value: selectedStop,
                        icon: const Icon(Icons.arrow_downward),
                        isExpanded: true,
                        elevation: 16,
                        style: const TextStyle(color: Colors.black),
                        underline: Container(
                          height: 2,
                          color: Colors.orange,
                        ),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            _updateSelectedStop(newValue); // Update and store selected stop
                          }
                        },
                        items: allStops.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _moveToNextStop,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        minimumSize: const Size(100, 40), // Adjust the size of the button
                      ),
                      child: const Text('NEXT'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  children: List.generate(availableStops.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: GestureDetector(
                        onTap: () => _onCardTapped(availableStops[index]),
                        child: Card(
                          color: availableStops[index] == selectedCard
                              ? Colors.orange
                              : Colors.grey.shade300,
                          child: Center(
                            child: Text(
                              availableStops[index],
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: selectedCard != null
                          ? () => _showReceipt(true) // Discounted fare
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        minimumSize: const Size(150, 60), // Adjust the size of the button
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'DISCOUNTED',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₱${discountedFare.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: selectedCard != null
                          ? () => _showReceipt(false) // Regular fare
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        minimumSize: const Size(150, 60), // Adjust the size of the button
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'REGULAR',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₱${regularFare.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showOverlay)
            AnimatedOverlay(
              message: "Routes have been reversed", // Provide message parameter
              show: showOverlay, // Provide show parameter
            ),
        ],
      ),
    );
  }
}
