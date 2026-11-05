import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_provider.dart';
import 'incident_detail_screen.dart';

class IncidentsListScreen extends StatefulWidget {
  const IncidentsListScreen({super.key});

  @override
  State<IncidentsListScreen> createState() => _IncidentsListScreenState();
}

class _IncidentsListScreenState extends State<IncidentsListScreen> {
  final List<String> _categories = [
    'All',
    'Broken Facilities',
    'Water Shortage',
    'Electricity Outage',
    'Damaged Furniture',
    'Sanitation Problem',
    'Safety Concern',
  ];

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Incidents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_outlined),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
            ),
            child: Column(
              children: [
                // Category Filter
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: appProvider.selectedFilter == null ? 'All' : _categories[appProvider.selectedFilter!],
                        hint: const Text('Filter by category'),
                        isExpanded: true,
                        items: _categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            int? index;
                            for (int i = 0; i < _categories.length; i++) {
                              if (_categories[i] == value) {
                                index = i;
                                break;
                              }
                            }
                            appProvider.setFilter(index == 0 ? null : index);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Search
                TextField(
                  onChanged: (value) {
                    appProvider.setSearchQuery(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search incidents...',
                    prefixIcon: const Icon(Icons.search_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Incident List
          Expanded(
            child: appProvider.isFetchingIncidents
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async {
                      await appProvider.fetchIncidents();
                    },
                    child: appProvider.incidents.isEmpty
                        ? const Center(child: Text('No incidents found'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: appProvider.incidents.length,
                            itemBuilder: (context, index) {
                              final incident = appProvider.incidents[index];
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
                                  subtitle: Text(
                                    'Submitted ${_formatDate(incident.createdAt)}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                  trailing: Container(
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
                            },
                          ),
                  ),
          ),
        ],
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

  void _showSearchDialog(BuildContext context) {
    final appProvider = context.read<AppProvider>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Incidents'),
        content: TextField(
          onChanged: (value) {
            appProvider.setSearchQuery(value);
          },
          decoration: const InputDecoration(
            hintText: 'Enter search term...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              appProvider.fetchIncidents();
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}
