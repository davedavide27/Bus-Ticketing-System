import 'package:flutter/material.dart';
import 'receipt_screen.dart'; // Adjust the path based on your project structure


class BusTicketScreen extends StatefulWidget {
  final String startingStop;
  final bool reverseOrder; // Add the reverseOrder parameter

  const BusTicketScreen({
    Key? key,
    required this.startingStop,
    this.reverseOrder = false, // Default to false
  }) : super(key: key);

  @override
  _BusTicketScreenState createState() => _BusTicketScreenState();
}

class _BusTicketScreenState extends State<BusTicketScreen> {
  late List<String> allStops;
  late List<String> availableStops;
  String? selectedStop;
  String? selectedCard;

  // Fare data after the first 4 kilometers
  final List<Map<String, double>> fareSteps = [
    {'regular': 17.2, 'discounted': 13.7},
    {'regular': 19.5, 'discounted': 15.4},
    {'regular': 21.5, 'discounted': 17.2},
    {'regular': 23.75, 'discounted': 19.0},
    {'regular': 24.0, 'discounted': 20.8},
    {'regular': 28.25, 'discounted': 22.6},
    {'regular': 30.5, 'discounted': 24.4},
    {'regular': 32.5, 'discounted': 26.0},
    {'regular': 34.75, 'discounted': 27.8},
    {'regular': 34.0, 'discounted': 28.8},
    {'regular': 39.25, 'discounted': 31.4},
    {'regular': 41.5, 'discounted': 33.2},
  ];

  double regularFare = 0.0;
  double discountedFare = 0.0;

  @override
  void initState() {
    super.initState();
    allStops = [
      'BANCASI-DUMALAGAN KM 0',
      'CEMETERY KM 1',
      'BANCASI ROTUNDA KM 2',
      'IDEMI - TOYOTA KM 3',
      'LIBERTAD SPORTS COMPLEX KM 4',
      'FERNANDEZ - SALAS KM 5',
      'BUTUAN DOCTORS - DOTTIES KM 6',
      'CAILANO - DBP KM 7',
      'OCHOA KM 8',
      'ALBA - ZCC KM 9',
      'PALAWAN - J MARKETING KM 10',
      'BAAN VIADUCT - Flying V KM 11',
      'Filinvest KM 12',
      'Eastwood - Wilton KM 13',
      'Tiniwisan Crossing KM 14',
      'PHISCI - Vista Man KM 15',
      'Ampayon Rotunda KM 16',
    ];

    // Check if we need to reverse the order of stops initially
    if (widget.reverseOrder) {
      allStops = allStops.reversed.toList();
    }

    // Set the initial selected stop and available stops
    selectedStop = widget.startingStop;
    _updateAvailableStops();
  }

  void _updateAvailableStops() {
    setState(() {
      int selectedIndex = allStops.indexOf(selectedStop!);
      availableStops = allStops.sublist(selectedIndex + 1);
    });
  }

  void _reverseStopsOrder() {
    setState(() {
      allStops = allStops.reversed.toList();
      // Adjust the KM numbers accordingly
      for (int i = 0; i < allStops.length; i++) {
        allStops[i] = allStops[i].replaceAll(RegExp(r'KM \d+'), 'KM $i');
      }
      // Reset the selected stop to the first stop in the new order
      selectedStop = allStops.first;
      _updateAvailableStops();
    });
  }

  void _moveToNextStop() {
    final currentIndex = allStops.indexOf(selectedStop!);
    if (currentIndex < allStops.length - 1) {
      setState(() {
        selectedStop = allStops[currentIndex + 1];
        _updateAvailableStops();
      });
    }
  }

  void _moveToPreviousStop() {
    final currentIndex = allStops.indexOf(selectedStop!);
    if (currentIndex > 0) {
      setState(() {
        selectedStop = allStops[currentIndex - 1];
        _updateAvailableStops();
      });
    }
  }

  void _onCardTapped(String stop) {
    setState(() {
      selectedCard = stop;
      _calculateFare(); // Recalculate fare when a card is selected
    });
  }

  void _calculateFare() {
    // Extract KM number from the selected starting and destination stops
    String? startKm = selectedStop?.split('KM ').last;
    String? destinationKm = selectedCard?.split('KM ').last;

    if (startKm != null && destinationKm != null) {
      int startKmNumber = int.parse(startKm);
      int destinationKmNumber = int.parse(destinationKm);
      int distance = destinationKmNumber - startKmNumber;

      if (distance > 0) {
        if (distance <= 4) {
          // First 4 kilometers
          setState(() {
            regularFare = 15.0;
            discountedFare = 12.0;
          });
        } else if (distance - 4 <= fareSteps.length) {
          // Beyond 4 kilometers, use the fareSteps list
          int fareIndex = distance - 5; // Because the first 4 kms are fixed

          setState(() {
            regularFare = fareSteps[fareIndex]['regular']!;
            discountedFare = fareSteps[fareIndex]['discounted']!;
          });
        } else {
          setState(() {
            regularFare = 0.0;
            discountedFare = 0.0;
          });
        }
      } else {
        setState(() {
          regularFare = 0.0;
          discountedFare = 0.0;
        });
      }
    }
  }

  void _showReceipt(bool isDiscounted) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptScreen(
          startingStop: selectedStop!,
          destinationStop: selectedCard!,
          fare: isDiscounted ? discountedFare : regularFare,
          isDiscounted: isDiscounted,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EZBUS UAT'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                Text("21:49"), // Mock time, adjust as needed
                SizedBox(width: 8),
                Icon(Icons.battery_std), // Mock battery icon, adjust as needed
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: _moveToPreviousStop,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
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
                        setState(() {
                          selectedStop = newValue;
                          _updateAvailableStops();
                          // Check if last stop is selected
                          if (newValue == 'Ampayon Rotunda KM 16') {
                            _reverseStopsOrder();
                          }
                        });
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
                      color: availableStops[index] == selectedCard ? Colors.orange : Colors.grey.shade300,
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
                      ? () {
                    _showReceipt(true); // Discounted fare
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: Text('DISCOUNTED\n₱${discountedFare.toStringAsFixed(2)}'),
                ),
                ElevatedButton(
                  onPressed: selectedCard != null
                      ? () {
                    _showReceipt(false); // Regular fare
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: Text('REGULAR\n₱${regularFare.toStringAsFixed(2)}'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
