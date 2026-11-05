import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_provider.dart';
import '../models/incident_model.dart';
import 'incident_detail_screen.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(Incident incident) async {
    final statusList = [
      'pending',
      'in_progress',
      'resolved',
      'closed',
    ];

    final selectedStatus = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: DropdownButtonFormField<String>(
          initialValue: incident.status,
          items: statusList.map((status) {
            return DropdownMenuItem(value: status, child: Text(status));
          }).toList(),
          onChanged: (value) {
            if (value != null) Navigator.pop(context, value);
          },
        ),
      ),
    );

    if (selectedStatus != null && mounted) {
      final appProvider = context.read<AppProvider>();
      final success = await appProvider.updateIncidentStatus(
        incident.id,
        selectedStatus,
        '',
      );

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appProvider.errorMessage ?? 'Failed to update status')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Incidents'),
            Tab(text: 'Pending'),
            Tab(text: 'In Progress'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All Incidents
          _buildIncidentList(appProvider),
          // Pending Incidents
          RefreshIndicator(
            onRefresh: () async {
              await appProvider.fetchIncidents(isPending: true);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: appProvider.incidents.length,
              itemBuilder: (context, index) {
                final incident = appProvider.incidents[index];
                if (incident.status != 'pending' && incident.status != 'in_progress') {
                  return const SizedBox.shrink();
                }
                return _buildIncidentCard(incident);
              },
            ),
          ),
          // In Progress Incidents
          RefreshIndicator(
            onRefresh: () async {
              await appProvider.fetchIncidents(isPending: true);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: appProvider.incidents.length,
              itemBuilder: (context, index) {
                final incident = appProvider.incidents[index];
                if (incident.status != 'in_progress') {
                  return const SizedBox.shrink();
                }
                return _buildIncidentCard(incident);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentList(AppProvider appProvider) {
    return RefreshIndicator(
      onRefresh: () async {
        await appProvider.fetchIncidents();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appProvider.incidents.length,
        itemBuilder: (context, index) {
          final incident = appProvider.incidents[index];
          return _buildIncidentCard(incident);
        },
      ),
    );
  }

  Widget _buildIncidentCard(Incident incident) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getCategoryColor(incident.category),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              incident.category.isNotEmpty ? incident.category[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
        title: Text(incident.title),
        subtitle: Text('Submitted ${_formatDate(incident.createdAt)}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(incident.status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                incident.status,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(height: 4),
            if (incident.status == 'pending' || incident.status == 'in_progress') ...[
              GestureDetector(
                onTap: () => _updateStatus(incident),
                child: const Icon(Icons.edit_outlined, size: 20),
              ),
            ],
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => IncidentDetailScreen(incident: incident),
            ),
          );
        },
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Broken Facilities': return Colors.orange;
      case 'Water Shortage': return Colors.blue;
      case 'Electricity Outage': return Colors.red;
      case 'Damaged Furniture': return Colors.purple;
      case 'Sanitation Problem': return Colors.green;
      case 'Safety Concern': return Colors.pink;
      default: return Colors.grey;
    }
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
