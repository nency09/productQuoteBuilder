import 'package:flutter/material.dart';
import 'client.dart';

class ClientInfoForm extends StatelessWidget {
  final Client client;
  final Function(Client) onChanged;

  const ClientInfoForm({
    super.key,
    required this.client,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Client Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Client Name',
                border: OutlineInputBorder(),
              ),
              initialValue: client.name,
              onChanged: (value) {
                onChanged(
                  Client(
                    name: value,
                    address: client.address,
                    referenceNumber: client.referenceNumber,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
              initialValue: client.address,
              maxLines: 3,
              onChanged: (value) {
                onChanged(
                  Client(
                    name: client.name,
                    address: value,
                    referenceNumber: client.referenceNumber,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Reference Number (Optional)',
                border: OutlineInputBorder(),
              ),
              initialValue: client.referenceNumber,
              onChanged: (value) {
                onChanged(
                  Client(
                    name: client.name,
                    address: client.address,
                    referenceNumber: value.isEmpty ? null : value,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
