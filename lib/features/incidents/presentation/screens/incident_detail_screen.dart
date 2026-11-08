import 'package:flutter/material.dart';

class IncidentDetailScreen extends StatelessWidget {
  final String incidentId;
  
  const IncidentDetailScreen({super.key, required this.incidentId});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Incident Details')),
      body: Center(child: Text('Incident $incidentId - To be implemented')),
    );
  }
}
