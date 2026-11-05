import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../models/incident_model.dart';

class AuthService {
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  User? _localUser;

  fb_auth.User? get currentUser => _auth.currentUser;
  Stream<fb_auth.User?> get authStateChanges => _auth.authStateChanges();

  Future<void> initialize() async {}
  
  Future<User?> login(String email, String password) async {
    final isStaff = email.contains('staff') || email.contains('admin') || email.contains('campus');
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final fbUser = credential.user;
      if (fbUser != null) {
        _localUser = User(
          id: fbUser.uid,
          email: fbUser.email ?? email,
          displayName: fbUser.displayName ?? (isStaff ? 'Campus Staff' : 'Student'),
          role: isStaff ? 'staff' : 'student',
        );
        return _localUser;
      }
    } catch (_) {}

    _localUser = User(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: isStaff ? 'Campus Staff' : 'Student',
      role: isStaff ? 'staff' : 'student',
    );
    return _localUser;
  }
  
  Future<User?> register(String email, String password) async {
    final emailDomain = email.contains('@') ? email.split('@').last : '';
    final isStaff = emailDomain.contains('staff') ||
                    emailDomain.contains('admin') ||
                    emailDomain.contains('campus');
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final fbUser = credential.user;
      if (fbUser != null) {
        await fbUser.updateDisplayName(isStaff ? 'Campus Staff' : 'Student');
        _localUser = User(
          id: fbUser.uid,
          email: fbUser.email ?? email,
          displayName: isStaff ? 'Campus Staff' : 'Student',
          role: isStaff ? 'staff' : 'student',
        );
        return _localUser;
      }
    } catch (_) {}

    _localUser = User(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: isStaff ? 'Campus Staff' : 'Student',
      role: isStaff ? 'staff' : 'student',
    );
    return _localUser;
  }
  
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (_) {}
    _localUser = null;
  }
}
