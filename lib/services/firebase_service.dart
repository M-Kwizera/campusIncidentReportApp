import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/incident_model.dart';

enum IncidentCategory {
  brokenFacilities,
  waterShortage,
  electricityOutage,
  damagedFurniture,
  sanitationProblem,
  safetyConcern,
}

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  static const String incidentsCollection = 'incidents';
  static const String usersCollection = 'users';

  static final List<Incident> _mockIncidents = [
    Incident(
      id: '1',
      title: 'Broken Water Pipe in Library',
      description: 'Water pipe leaking on the 2nd floor near the study area.',
      category: 'Water Shortage',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      submittedBy: 'student1',
      submittedByEmail: 'student1@campus.edu',
      status: 'pending',
      priority: 2,
    ),
    Incident(
      id: '2',
      title: 'Power Outage in Science Block B',
      description: 'Electricity went off completely in labs 3 and 4.',
      category: 'Electricity Outage',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      submittedBy: 'student2',
      submittedByEmail: 'student2@campus.edu',
      status: 'in_progress',
      priority: 3,
    ),
    Incident(
      id: '3',
      title: 'Damaged Chairs in Lecture Hall 1',
      description: 'Several wooden chairs in row 4 are broken and unsafe.',
      category: 'Damaged Furniture',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      submittedBy: 'student3',
      submittedByEmail: 'student3@campus.edu',
      status: 'resolved',
      priority: 1,
    ),
  ];

  // Get all incidents
  Future<List<Incident>> getAllIncidents() async {
    try {
      final snapshot = await _firestore.collection(incidentsCollection).get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) => Incident.fromJson(doc.data())).toList();
      }
      return List.from(_mockIncidents);
    } catch (_) {
      return List.from(_mockIncidents);
    }
  }
  
  // Get pending incidents
  Future<List<Incident>> getPendingIncidents() async {
    try {
      final snapshot = await _firestore
          .collection(incidentsCollection)
          .where('status', whereIn: ['pending', 'in_progress'])
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) => Incident.fromJson(doc.data())).toList();
      }
      return _mockIncidents
          .where((inc) => inc.status == 'pending' || inc.status == 'in_progress')
          .toList();
    } catch (_) {
      return _mockIncidents
          .where((inc) => inc.status == 'pending' || inc.status == 'in_progress')
          .toList();
    }
  }
  
  // Get incident by ID
  Future<Incident?> getIncidentById(String id) async {
    try {
      final doc = await _firestore.collection(incidentsCollection).doc(id).get();
      if (doc.exists) {
        return Incident.fromJson(doc.data()!);
      }
    } catch (_) {}
    try {
      return _mockIncidents.firstWhere((inc) => inc.id == id);
    } catch (_) {
      return null;
    }
  }
  
  // Submit new incident
  Future<bool> submitIncident(Incident incident) async {
    try {
      await _firestore.collection(incidentsCollection).add(incident.toJson());
      _mockIncidents.insert(0, incident);
      return true;
    } catch (_) {
      _mockIncidents.insert(0, incident);
      return true;
    }
  }
  
  // Update incident status
  Future<bool> updateIncidentStatus(
    String id,
    String status,
    String? description,
  ) async {
    try {
      await _firestore.collection(incidentsCollection).doc(id).update({
        'status': status,
        if (description != null && description.isNotEmpty) 'resolutionNotes': description,
      });
    } catch (_) {}

    final index = _mockIncidents.indexWhere((inc) => inc.id == id);
    if (index != -1) {
      final old = _mockIncidents[index];
      _mockIncidents[index] = Incident(
        id: old.id,
        title: old.title,
        description: old.description,
        category: old.category,
        createdAt: old.createdAt,
        submittedBy: old.submittedBy,
        submittedByEmail: old.submittedByEmail,
        images: old.images,
        status: status,
        priority: old.priority,
      );
    }
    return true;
  }
  
  // Upload image
  Future<String> uploadImage(String filePath) async {
    try {
      final ref = _storage.ref('incidents/${DateTime.now().millisecondsSinceEpoch}/$filePath');
      final snapshot = await ref.putFile(File(filePath));
      final downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (_) {
      return filePath;
    }
  }
  
  // Delete image
  Future<void> deleteImage(String filePath) async {
    try {
      final ref = _storage.ref('incidents/${DateTime.now().millisecondsSinceEpoch}/$filePath');
      await ref.delete();
    } catch (_) {}
  }
}
