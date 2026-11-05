import 'package:flutter/foundation.dart';
import '../models/incident_model.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';

class AppProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseService _firebaseService = FirebaseService();
  
  // User State
  User? currentUser;
  bool isLoading = false;
  String? errorMessage;
  
  // Incident State
  List<Incident> incidents = [];
  bool isFetchingIncidents = false;
  int? selectedFilter;
  String? searchQuery;
  
  // Navigation
  String currentScreen = 'splash';
  
  // Initialize
  AppProvider() {
    _initializeApp();
  }
  
  Future<void> _initializeApp() async {
    await _authService.initialize();
    await fetchIncidents();
    notifyListeners();
  }
  
  // Auth Methods
  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    try {
      final user = await _authService.login(email, password);
      currentUser = user;
      await fetchIncidents();
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
    }
  }
  
  Future<bool> register(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    try {
      final user = await _authService.register(email, password);
      currentUser = user;
      await fetchIncidents();
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
    }
  }
  
  Future<void> logout() async {
    await _authService.logout();
    currentUser = null;
    incidents = [];
    selectedFilter = null;
    searchQuery = null;
    notifyListeners();
  }
  
  // Incident Methods
  Future<void> fetchIncidents({bool? isPending}) async {
    isFetchingIncidents = true;
    errorMessage = null;
    try {
      if (isPending == true) {
        incidents = await _firebaseService.getPendingIncidents();
      } else {
        incidents = await _firebaseService.getAllIncidents();
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isFetchingIncidents = false;
      notifyListeners();
    }
  }
  
  Future<bool> submitIncident(Incident incident) async {
    isLoading = true;
    errorMessage = null;
    try {
      final success = await _firebaseService.submitIncident(incident);
      if (success) {
        await fetchIncidents();
      }
      return success;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
    }
  }
  
  Future<bool> updateIncidentStatus(String incidentId, String status, String? description) async {
    isLoading = true;
    errorMessage = null;
    try {
      final success = await _firebaseService.updateIncidentStatus(
        incidentId,
        status,
        description,
      );
      if (success) {
        await fetchIncidents();
      }
      return success;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
    }
  }
  
  // Filter
  void setFilter(int? filter) {
    selectedFilter = filter;
    notifyListeners();
  }
  
  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }
}
