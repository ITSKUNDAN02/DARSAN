import 'package:flutter/material.dart';

class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tickets')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Ticket Offers',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: const [
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.flight_takeoff),
                      title: Text('Kathmandu to Pokhara'),
                      subtitle: Text('From NPR 5,500'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.flight),
                      title: Text('Kathmandu to Nagarkot'),
                      subtitle: Text('From NPR 2,000'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.train),
                      title: Text('Kathmandu to Chitwan'),
                      subtitle: Text('From NPR 1,800'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
