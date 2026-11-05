import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_provider.dart';
import '../models/incident_model.dart';

class IncidentDetailScreen extends StatelessWidget {
  final Incident incident;

  const IncidentDetailScreen({super.key, required this.incident});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(incident.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: _getCategoryGradient(incident.category),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    incident.category,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    incident.title,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _getStatusColor(incident.status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    incident.status.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Description
            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(incident.description),
            const SizedBox(height: 20),
            // Images
            if (incident.images.isNotEmpty) ...[
              Text(
                'Attachments (${incident.images.length})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ...incident.images.map((imagePath) => _buildImageCard(imagePath)),
            ],
            const SizedBox(height: 20),
            // Submitted by
            Text(
              'Submitted by ${_getUserName(context, incident.submittedBy)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (incident.submittedByEmail != null) ...[
              const SizedBox(height: 4),
              Text('Email: ${incident.submittedByEmail}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(String imagePath) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(imagePath, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.broken_image, size: 50));
        }),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'in_progress': return Colors.blue;
      case 'resolved': return Colors.green;
      case 'closed': return Colors.grey;
      default: return Colors.grey;
    }
  }

  List<Color> _getCategoryGradient(String category) {
    switch (category) {
      case 'Broken Facilities': return [Colors.orange.shade400, Colors.orange.shade700];
      case 'Water Shortage': return [Colors.blue.shade400, Colors.blue.shade700];
      case 'Electricity Outage': return [Colors.red.shade400, Colors.red.shade700];
      case 'Damaged Furniture': return [Colors.purple.shade400, Colors.purple.shade700];
      case 'Sanitation Problem': return [Colors.green.shade400, Colors.green.shade700];
      case 'Safety Concern': return [Colors.pink.shade400, Colors.pink.shade700];
      default: return [Colors.grey.shade400, Colors.grey.shade700];
    }
  }

  String _getUserName(BuildContext context, String? userId) {
    if (userId == null) return 'Anonymous';
    final user = context.read<AppProvider>().currentUser;
    if (user?.id == userId) return 'You';
    return 'Student';
  }
}
