import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Admin credentials
  static const String adminEmail = 'admin@gmail.com';
  static const String adminPassword = '123456789';

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
      
      // Check if this is the admin account and ensure admin role is set
      if (email.toLowerCase() == adminEmail && password == adminPassword) {
        await _ensureAdminRole(userCredential.user!.uid);
      }
      
      // Update last login time
      await updateLastLogin(userCredential.user!.uid);
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      developer.log('Firebase Auth Exception during sign in: ${e.code}', error: e);
      throw _handleAuthException(e);
    } catch (e) {
      developer.log('Unexpected error during sign in', error: e);
      throw Exception('Failed to sign in: $e');
    }
  }

  // Ensure the admin role is set for the admin user
  Future<void> _ensureAdminRole(String uid) async {
    try {
      developer.log('Ensuring admin role for user: $uid');
      await _firestore.collection('users').doc(uid).set({
        'role': 'admin',
        'firstName': 'Admin',
        'lastName': 'User',
        'fullName': 'Admin User',
        'email': adminEmail,
        'lastLoginAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'active': true,
      }, SetOptions(merge: true));
      developer.log('Admin role verified for user: $uid');
    } catch (e) {
      developer.log('Error setting admin role: $e', error: e);
    }
  }

  // Check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    try {
      final user = currentUser;
      if (user == null) {
        developer.log('isCurrentUserAdmin: No current user');
        return false;
      }
      
      // Special case - if email matches admin email, consider admin
      if (user.email?.toLowerCase() == adminEmail) {
        developer.log('isCurrentUserAdmin: User email matches admin email');
        return true;
      }
      
      developer.log('Checking admin status for UID: ${user.uid}');
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        developer.log('isCurrentUserAdmin: User document not found');
        return false;
      }
      
      final role = userDoc.data()?['role'] as String?;
      developer.log('User role: $role');
      return role == 'admin';
    } catch (e) {
      developer.log('Error checking admin status: $e', error: e);
      return false;
    }
  }

  // Sign up with email and password
  Future<UserCredential> createUserWithEmailAndPassword(
    String email, 
    String password, 
    String firstName,
    String lastName,
    {String role = 'user'}
  ) async {
    try {
      developer.log('Attempting to create user with email: $email');
      // Check if this is admin account being created
      bool isAdminAccount = email.toLowerCase() == adminEmail;
      if (isAdminAccount) {
        role = 'admin';
        developer.log('Creating admin account');
      }
      
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
        role: role
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
    {String role = 'user'}
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
        'role': role,
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

  // Get all users (for admin)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      developer.log('Fetching all users');
      final querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Include document ID
        return data;
      }).toList();
    } catch (e) {
      developer.log('Error fetching users', error: e);
      throw Exception('Failed to fetch users: $e');
    }
  }

  // Delete user (for admin)
  Future<void> deleteUser(String uid) async {
    try {
      developer.log('Deleting user with UID: $uid');
      
      // Don't allow deletion of admin account
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null && 
            userData['email'] == adminEmail && 
            userData['role'] == 'admin') {
          throw Exception('Cannot delete admin account');
        }
      }
      
      // Delete user document from Firestore first
      await _firestore.collection('users').doc(uid).delete();
      
      // If admin is deleting another user, use admin SDK or custom function
      // This would typically be done through Firebase Functions
      // For this example, we'll just log it
      developer.log('User document deleted from Firestore for UID: $uid');
      
      // Note: To actually delete the Auth account would require either:
      // 1. The user to be signed in (can't be done for other users)
      // 2. Admin SDK on the backend (Firebase Cloud Functions)
      // Instead, mark the user as inactive
      await _firestore.collection('deleted_users').doc(uid).set({
        'deletedAt': FieldValue.serverTimestamp(),
      });
      
    } catch (e) {
      developer.log('Error deleting user', error: e);
      throw Exception('Failed to delete user: $e');
    }
  }

  // Update user (for admin)
  Future<void> updateUser(String uid, Map<String, dynamic> userData) async {
    try {
      developer.log('Updating user with UID: $uid');
      
      // Don't allow changing admin role of the main admin account
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final existingData = userDoc.data();
        if (existingData != null && existingData['email'] == adminEmail) {
          // Ensure role remains 'admin' for admin account
          userData['role'] = 'admin';
        }
      }
      
      await _firestore.collection('users').doc(uid).update(userData);
      developer.log('User updated successfully');
    } catch (e) {
      developer.log('Error updating user', error: e);
      throw Exception('Failed to update user: $e');
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