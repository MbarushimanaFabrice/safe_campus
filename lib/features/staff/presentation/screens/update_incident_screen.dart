import 'package:flutter/material.dart';

class UpdateIncidentScreen extends StatelessWidget {
  final String incidentId;
  
  const UpdateIncidentScreen({super.key, required this.incidentId});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Incident')),
      body: Center(child: Text('Update Incident $incidentId - To be implemented')),
    );
  }
}
