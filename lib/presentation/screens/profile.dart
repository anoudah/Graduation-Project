import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/localization/app_localizations.dart';
import 'login_screen.dart'; 

/// Centralized color palette specific to the Profile screen.
class ProfileColors {
  static const Color primary = Color(0xFF6B4B8A); 
  static const Color background = Color(0xFFF5F5F5); 
  static const Color cardGrey = Color(0xFFE0E0E0);
  static const Color danger = Color(0xFFD32F2F); 
}

/// --- PRESENTATION LAYER ---
/// [ProfilePage] allows users to manage their personal information and account settings.
/// 
/// Key features:
/// * Fetches and displays user data from Firestore.
/// * Updates user profile information (Name, Gender).
/// * Handles sensitive account actions (Logout, Deletion) with security safeguards.
class ProfilePage extends StatefulWidget {
  final String? uid;
  const ProfilePage({super.key, this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // --- STATE VARIABLES ---
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  String gender = 'Male'; 

  @override
  void initState() {
    super.initState();
    _loadUserData(); 
  }

  /// Fetches the authenticated user's data from the Firestore 'Users' collection.
  /// 
  /// Populates the controllers and ensures the gender string is formatted
  /// to match the dropdown menu options.
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      if (userDoc.exists) {
        setState(() {
          fullNameController.text = userDoc['Full_Name'] ?? '';
          emailController.text = userDoc['Email'] ?? user.email ?? '';
          
          String fetchedGender = userDoc['gender'] ?? 'Male';
          if (fetchedGender.isNotEmpty) {
            gender = fetchedGender[0].toUpperCase() + fetchedGender.substring(1).toLowerCase();
          }
        });
      } else {
        setState(() {
          emailController.text = user.email ?? '';
        });
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
    }
  }

  /// Logs the user out of the application and clears the navigation stack.
  Future<void> _logOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  /// Permanently deletes the user's account and all associated data.
  /// 
  /// This process follows a strict sequence:
  /// 1. Deletes user records from 'User_Interactions'.
  /// 2. Deletes the profile document from the 'Users' collection.
  /// 3. Deletes the authentication record from Firebase Auth.
  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final String uid = user.uid;
      final firestore = FirebaseFirestore.instance;

      // 1. Delete all User Interactions
      QuerySnapshot interactionDocs = await firestore
          .collection('User_Interactions')
          .where('User_Id', isEqualTo: uid)
          .get();

      WriteBatch batch = firestore.batch();
      for (var doc in interactionDocs.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // 2. Delete user data from Firestore
      await firestore.collection('Users').doc(uid).delete();
      
      // 3. Delete user from Firebase Auth
      await user.delete();

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
      
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        if (!mounted) return;
        
        // --- ACTIONABLE SNACKBAR ---
        // Provides a direct 'Logout' action to help users clear the security requirement.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('For security, you must log in again to delete your account.'),
            backgroundColor: ProfileColors.danger,
            duration: const Duration(seconds: 8),
            action: SnackBarAction(
              label: 'LOGOUT',
              textColor: Colors.white,
              onPressed: _logOut, 
            ),
          ),
        );
      } else {
        debugPrint("Auth Error: $e");
      }
    } catch (e) {
      debugPrint("Error deleting account: $e");
    }
  }

  /// Displays a confirmation dialog before logging out.
  void _showLogOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); 
              _logOut(); 
            },
            style: ElevatedButton.styleFrom(backgroundColor: ProfileColors.primary),
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Displays a high-alert dialog before account deletion.
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Account', style: TextStyle(color: ProfileColors.danger)),
        content: const Text('This action is permanent and cannot be undone. All your data will be erased. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            style: ElevatedButton.styleFrom(backgroundColor: ProfileColors.danger),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfileColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).profile, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          // --- NAVIGATION FIX ---
          // Explicitly calling pop() ensures the user can leave the screen 
          // even if an authentication error has occurred.
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: ProfileColors.cardGrey,
              child: Icon(Icons.person, size: 50, color: ProfileColors.primary),
            ),
            const SizedBox(height: 30),
            
            _buildTextField(AppLocalizations.of(context).fullName, fullNameController),
            const SizedBox(height: 20),
            
            _buildTextField(AppLocalizations.of(context).email, emailController, enabled: false),
            const SizedBox(height: 20),
            
            _buildDropdownField(AppLocalizations.of(context).gender, gender, ['Male', 'Female'], (String? newValue) {
              setState(() {
                gender = newValue!;
              });
            }),
            
            const SizedBox(height: 40),
            
            /// Saves profile updates to Firestore.
            ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;
                
                final successMessage = AppLocalizations.of(context).profileUpdatedSuccessfully;
                final failureMessage = AppLocalizations.of(context).couldNotSaveChanges;

                try {
                  await FirebaseFirestore.instance.collection('Users').doc(user.uid).update({
                    'Full_Name': fullNameController.text.trim(),
                    'gender': gender,
                    'Last_Update': Timestamp.now(),
                  });

                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(successMessage),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  debugPrint("Error updating profile: $e");
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(failureMessage)),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ProfileColors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(AppLocalizations.of(context).saveChanges, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            
            const SizedBox(height: 20),
            const Divider(color: ProfileColors.cardGrey, thickness: 1),
            const SizedBox(height: 10),

            OutlinedButton.icon(
              onPressed: _showLogOutDialog,
              icon: const Icon(Icons.logout, color: ProfileColors.primary),
              label: const Text('Log Out', style: TextStyle(color: ProfileColors.primary, fontSize: 16, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: ProfileColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 12),

            TextButton.icon(
              onPressed: _showDeleteAccountDialog,
              icon: const Icon(Icons.delete_forever, color: ProfileColors.danger),
              label: const Text('Delete Account', style: TextStyle(color: ProfileColors.danger, fontSize: 16, fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Builds a standardized text input field.
  Widget _buildTextField(String label, TextEditingController controller, {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  /// Builds a standardized dropdown field.
  Widget _buildDropdownField(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}