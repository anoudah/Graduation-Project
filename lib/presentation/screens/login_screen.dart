import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- Core Imports ---
import '../../core/theme.dart';
import '../../core/localization/localization_extension.dart';

// --- Screen Imports ---
import 'home_screen.dart';
import 'signup_screen.dart'; 

/// --- PRESENTATION LAYER ---
/// [LoginScreen] handles user authentication via Firebase Email/Password.
///
/// It features form validation, password visibility toggling, a loading state 
/// to prevent duplicate submissions, and a password reset flow.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // --- STATE VARIABLES ---
  
  /// GlobalKey used to validate the email and password form fields.
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// Controls the visual loading spinner and disables the login button during network requests.
  bool _isLoading = false;
  
  /// Toggles the visual obscuring of the password text field.
  bool _obscurePassword = true;

  // --- AUTHENTICATION FUNCTIONS ---

  /// Displays a dialog allowing the user to reset their password.
  /// 
  /// Takes [loc] (the localized strings object) as a parameter. Passing this down
  /// prevents fatal 'Provider out of tree' crashes that occur when trying to access
  /// context listeners inside asynchronous dialogs.
  void _showForgotPasswordDialog(dynamic loc) {
    final TextEditingController resetEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          loc.resetPassword, 
          style: const TextStyle(color: AppColors.primary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(loc.resetPasswordInstructions),
            const SizedBox(height: 15),
            TextField(
              controller: resetEmailController,
              decoration: InputDecoration(
                hintText: loc.emailAddress,
                prefixIcon: const Icon(Icons.email, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              loc.cancel,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              if (resetEmailController.text.isNotEmpty) {
                final resetLinkSentMessage = loc.resetLinkSent;
                final errorLabel = loc.error;

                try {
                  // Request Firebase to send a password reset email
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                    email: resetEmailController.text.trim(),
                  );
                  
                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext); // Close the dialog on success
                  
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text(resetLinkSentMessage)),
                  );
                } catch (e) {
                  if (!dialogContext.mounted) return;
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text("$errorLabel: ${e.toString()}")),
                  );
                }
              }
            },
            child: Text(
              loc.send,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Free up memory by disposing controllers when the screen is destroyed
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Processes the login request with Firebase Authentication.
  /// 
  /// [loc] is passed directly from the `build` method to ensure localized error
  /// messages can be displayed safely without triggering context-listener crashes 
  /// during async operations.
  Future<void> _handleLogin(dynamic loc) async {
    // 1. Validate the form (checks if fields are empty)
    if (_formKey.currentState!.validate()) {
      // 2. Trigger loading UI
      setState(() => _isLoading = true);
      
      // Store translations locally to survive async gaps safely
      final defaultErrorMessage = loc.error;

      try {
        // 3. Authenticate with Firebase
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        // 4. Verify the user has a corresponding document in the Firestore 'Users' collection
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          if (!mounted) return;
          // 5. Navigate to Home Screen and clear the back-stack
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        } else {
          // Edge Case: User exists in Auth but their database profile was deleted
          throw "User data not found in Database";
        }
      } on FirebaseAuthException catch (e) {
        String message = defaultErrorMessage; // Fallback error

        if (e.code == 'user-not-found') {
          // This triggers ONLY if Email Enumeration Protection is OFF in Firebase Console
          message = "No account found under this email."; 
        } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
          // This triggers if the password is wrong, OR if Enumeration Protection is ON
          message = "Invalid email or password. Please try again.";
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        
      } catch (e) {
        // Catch-all for network or database errors
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        
      } finally {
        // 7. Always remove the loading spinner, regardless of success or failure
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    // --- CRITICAL ARCHITECTURE PATTERN ---
    // Extract localizations once at the top of the build method. 
    // This allows us to pass the 'loc' object into async functions safely, 
    // avoiding the "Tried to listen to a value... from outside the widget tree" crash.
    final loc = context.loc;

    return Scaffold(
      backgroundColor: AppColors.background,
      
      // --- BACK BUTTON MAGIC ---
      // This allows the AppBar to float transparently over the body 
      // without pushing the "WASEL" logo downwards.
      extendBodyBehindAppBar: true, 
      
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textMain),
          onPressed: () {
            // Defensive check: only pop if there is a screen to go back to
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      // -------------------------

      body: _isLoading
          ? const Center(
              // Shows while Firebase is processing the login
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // --- LOGO & GREETING ---
                      const SizedBox(height: 100),
                      const Text(
                        "WASEL",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        loc.welcomeBack, 
                        style: const TextStyle(
                          fontSize: 18,
                          color: AppColors.textMain,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        loc.loginToYourAccount, 
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 50),

                      // --- INPUT FIELDS ---
                      _buildTextField(
                        loc.emailAddress,
                        Icons.email_outlined,
                        _emailController,
                        loc, 
                      ),
                      const SizedBox(height: 20),

                      _buildTextField(
                        loc.password,
                        Icons.lock_outline,
                        _passwordController,
                        loc, 
                        isPassword: _obscurePassword,
                        // Interactive suffix icon to reveal/hide the password
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.iconGrey,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),

                      // --- FORGOT PASSWORD ---
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _showForgotPasswordDialog(loc), 
                          child: Text(
                            loc.forgotPassword,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // --- LOGIN BUTTON ---
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () => _handleLogin(loc), 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            loc.login,
                            style: AppTextStyles.buttonText,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --- SIGN UP REDIRECT ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            loc.dontHaveAnAccount,
                            style: const TextStyle(color: AppColors.textMain),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignUpScreen(),
                                ),
                              );
                            },
                            child: Text(
                              loc.signup,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  /// A highly reusable UI helper to construct uniform styled text inputs.
  /// 
  /// Inherits the [loc] object to provide localized validation error messages.
  Widget _buildTextField(
    String hint,
    IconData icon,
    TextEditingController controller,
    dynamic loc, {
    bool isPassword = false,
    Widget? suffixIcon,
    bool isOptional = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword, // Hides text if it's a password field
      style: const TextStyle(color: AppColors.textMain),
      // Basic validation: Returns an error string if a required field is left empty
      validator: (value) =>
          (!isOptional && (value == null || value.isEmpty)) ? loc.requiredField : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint),
        prefixIcon: Icon(icon, color: AppColors.primary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
