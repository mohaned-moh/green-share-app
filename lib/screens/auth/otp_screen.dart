import 'package:flutter/material.dart';
import 'package:green_share/core/app_theme.dart';
import 'package:green_share/screens/main_tab_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:green_share/services/database_service.dart';
import 'package:green_share/models/user_model.dart';
import 'package:green_share/main.dart'; 

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final ConfirmationResult? webConfirmationResult;
  
  // Optional Signup Fields
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? password;
  final String? role;
  final String? crNumber;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    this.webConfirmationResult,
    this.firstName,
    this.lastName,
    this.email,
    this.password,
    this.role,
    this.crNumber,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  final DatabaseService _databaseService = DatabaseService();

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.invalidOtp)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential;
      if (widget.webConfirmationResult != null) {
        userCredential = await widget.webConfirmationResult!.confirm(otp);
      } else {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: widget.verificationId,
          smsCode: otp,
        );
        userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      }

      final user = userCredential.user;
      if (user != null) {
        // Link email and password if provided during signup
        if (widget.email != null && widget.email!.isNotEmpty && widget.password != null && widget.password!.isNotEmpty) {
          try {
            final emailCred = EmailAuthProvider.credential(email: widget.email!, password: widget.password!);
            await user.linkWithCredential(emailCred);
          } catch(e) {
            // Might already be linked or email already in use by another account
            print("Could not link email credential: $e");
          }
        }

        // Check if user profile exists
        final userProfile = await _databaseService.getUserProfile(user.uid);
        if (userProfile == null) {
          String fullName = 'Phone User';
          if (widget.firstName != null && widget.lastName != null) {
             fullName = '${widget.firstName} ${widget.lastName}';
          }
          
          final newUserModel = UserModel(
            id: user.uid,
            name: fullName,
            email: widget.email ?? '',
            role: widget.role ?? 'User',
            phoneNumber: widget.phoneNumber,
            crNumber: widget.crNumber,
            createdAt: DateTime.now(),
          );
          await _databaseService.createUserProfile(newUserModel);
        }

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainTabScreen()),
            (route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? context.l10n.invalidOtp)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.unexpectedError(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Card(
              margin: const EdgeInsets.all(24.0),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.message_outlined, size: 64, color: AppTheme.primaryColor),
                    const SizedBox(height: 24),
                    Text(
                      context.l10n.verifyCode,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${context.l10n.enterOtp} sent to ${widget.phoneNumber}',
                      style: const TextStyle(fontSize: 14, color: AppTheme.textSecondaryColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: _otpController,
                      decoration: InputDecoration(
                        labelText: context.l10n.enterOtp,
                        prefixIcon: const Icon(Icons.password),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                    ),
                    const SizedBox(height: 32),
                    _isLoading 
                      ? const Center(child: CircularProgressIndicator()) 
                      : ElevatedButton(
                          onPressed: _verifyOtp,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                          ),
                          child: Text(context.l10n.verifyCode),
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
