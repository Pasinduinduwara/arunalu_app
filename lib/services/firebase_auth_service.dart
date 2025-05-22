import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream to listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      developer.log('Attempting to sign in with email: $email');
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      developer.log('Successfully signed in user: ${userCredential.user?.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      developer.log('Firebase Auth Exception during sign in: ${e.code}', error: e);
      throw _handleAuthException(e);
    } catch (e) {
      developer.log('Unexpected error during sign in', error: e);
      throw Exception('Failed to sign in: $e');
    }
  }

  // Sign up with email and password
  Future<UserCredential> createUserWithEmailAndPassword(
    String email, 
    String password, 
    String firstName,
    String lastName,
  ) async {
    try {
      developer.log('Attempting to create user with email: $email');
      // Create the user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      developer.log('User created successfully: ${userCredential.user?.uid}');
      
      // Set display name for the user
      await userCredential.user?.updateDisplayName('$firstName $lastName');
      developer.log('Display name updated for user: ${userCredential.user?.uid}');
      
      // Create a user profile in Firestore
      await _createUserProfile(
        userCredential.user!.uid,
        email,
        firstName,
        lastName,
      );
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      developer.log('Firebase Auth Exception during registration: ${e.code}', error: e);
      throw _handleAuthException(e);
    } catch (e) {
      developer.log('Unexpected error during registration', error: e);
      throw Exception('Failed to register: $e');
    }
  }

  // Create user profile in Firestore
  Future<void> _createUserProfile(
    String uid, 
    String email, 
    String firstName, 
    String lastName,
  ) async {
    try {
      developer.log('Creating user profile in Firestore for UID: $uid');
      final userData = {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'fullName': '$firstName $lastName',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'active': true,
      };
      
      // Use set with merge to ensure we don't overwrite existing data if the document exists
      await _firestore.collection('users').doc(uid).set(userData, SetOptions(merge: true));
      
      // Verify data was written correctly by reading it back
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      if (!docSnapshot.exists) {
        developer.log('Failed to verify user data was saved properly for UID: $uid');
        throw Exception('Failed to verify user data was saved properly.');
      }
      
      developer.log('User data successfully written to Firestore for uid: $uid');
    } catch (e) {
      developer.log('Error creating user profile in Firestore', error: e);
      // Re-throw the exception to be handled by the calling function
      throw Exception('Failed to create user profile in database: $e');
    }
  }

  // Get user profile from Firestore
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = currentUser;
      if (user == null) {
        developer.log('Cannot get user profile: No user is currently logged in');
        return null;
      }
      
      developer.log('Fetching user profile for UID: ${user.uid}');
      final docSnapshot = await _firestore.collection('users').doc(user.uid).get();
      if (docSnapshot.exists) {
        developer.log('User profile retrieved successfully');
        return docSnapshot.data();
      }
      developer.log('No user profile found for UID: ${user.uid}');
      return null;
    } catch (e) {
      developer.log('Error getting user profile', error: e);
      return null;
    }
  }

  // Update user last login time
  Future<void> updateLastLogin(String uid) async {
    try {
      developer.log('Updating last login time for UID: $uid');
      await _firestore.collection('users').doc(uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
      developer.log('Last login time updated successfully');
    } catch (e) {
      developer.log('Error updating last login time', error: e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      developer.log('Signing out user');
      await _auth.signOut();
      developer.log('User signed out successfully');
    } catch (e) {
      developer.log('Error signing out', error: e);
      throw Exception('Failed to sign out: $e');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      developer.log('Sending password reset email to: $email');
      await _auth.sendPasswordResetEmail(email: email);
      developer.log('Password reset email sent successfully');
    } on FirebaseAuthException catch (e) {
      developer.log('Firebase Auth Exception during password reset', error: e);
      throw _handleAuthException(e);
    } catch (e) {
      developer.log('Unexpected error during password reset', error: e);
      throw Exception('Failed to send password reset email: $e');
    }
  }

  // Handle Firebase Auth exceptions
  Exception _handleAuthException(FirebaseAuthException e) {
    developer.log('Handling Firebase Auth Exception: ${e.code}', error: e);
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email.');
      case 'wrong-password':
        return Exception('Incorrect password.');
      case 'email-already-in-use':
        return Exception('Email is already in use.');
      case 'weak-password':
        return Exception('The password is too weak.');
      case 'invalid-email':
        return Exception('The email address is invalid.');
      case 'operation-not-allowed':
        return Exception('Email/password accounts are not enabled.');
      case 'too-many-requests':
        return Exception('Too many attempts. Try again later.');
      case 'network-request-failed':
        return Exception('Network error. Check your internet connection.');
      default:
        return Exception('An error occurred: ${e.message ?? e.code}');
    }
  }
} 