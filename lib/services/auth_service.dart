import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../model/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Signup with email and password
  Future<User?> signupWithEmail(String email, String password, String username) async {
    try {
      // // Check if username is already taken
      // if (await isUsernameTaken(username)) {
      //   throw Exception('Username is already taken');
      // }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Create a new user document in Firestore
        await _createUserInFirestore(userCredential.user!.uid, email, username);
      }

      return userCredential.user;
    } catch (e) {
      debugPrint("Signup Error: $e");
      return null;
    }
  }

  // Check if username is already taken
  Future<bool> isUsernameTaken(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint("Error checking username: $e");
      return true; // Return true in case of error to prevent signup with potential username issue
    }
  }

  // Create user document in Firestore
  Future<void> _createUserInFirestore(String uid, String email, String username) async {
    try {
      UserModel newUser = UserModel(
        id: uid,
        username: username,
        email: email,
        role: UserRole.employer, // Default role is set to employer
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(newUser.toMap());
      debugPrint("User created in Firestore");
    } catch (e) {
      debugPrint("Error creating user in Firestore: $e");

      // Optional: Delete the user from Auth if Firestore creation fails
      await _auth.currentUser?.delete();
      debugPrint("User deleted from Auth due to Firestore failure");
    }
  }

  // Login with email and password
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      debugPrint("Login Error: $e");
      return null;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint("Password reset email sent");
    } catch (e) {
      debugPrint("Password Reset Error: $e");
    }
  }

  // Get current user data from Firestore
  Future<UserModel?> getCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }
      } catch (e) {
        debugPrint("Error getting current user data: $e");
      }
    }
    return null;
  }

  // Sign out
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
