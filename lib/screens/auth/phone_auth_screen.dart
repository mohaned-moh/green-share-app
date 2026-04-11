import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:green_share/core/app_theme.dart';
import 'package:green_share/screens/auth/otp_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:green_share/main.dart'; // for context.l10n
import 'package:provider/provider.dart';
import 'package:green_share/providers/locale_provider.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  void _navigateToOtp(String verificationId, [ConfirmationResult? webResult]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpScreen(
          phoneNumber: _phoneController.text.trim(),
          verificationId: verificationId,
          webConfirmationResult: webResult,
        ),
      ),
    );
  }

  Future<void> _verifyPhone() async {
    String phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.pleaseFillAllFields)),
      );
      return;
    }

    // Auto-format Jordanian number to E.164 format for Firebase
    if (phone.startsWith('0')) {
      phone = '+962${phone.substring(1)}';
    } else if (!phone.startsWith('+')) {
      phone = '+962$phone';
    }

    setState(() => _isLoading = true);

    try {
      if (kIsWeb) {
        // Web requires signInWithPhoneNumber for reCAPTCHA
        ConfirmationResult result = await FirebaseAuth.instance.signInWithPhoneNumber(phone);
        if (mounted) {
          setState(() => _isLoading = false);
          _navigateToOtp(result.verificationId, result);
        }
      } else {
        // Mobile uses verifyPhoneNumber
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phone,
          verificationCompleted: (PhoneAuthCredential credential) async {
            // Auto verification
          },
          verificationFailed: (FirebaseAuthException e) {
            if (mounted) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.message ?? 'Verification failed')),
              );
            }
          },
          codeSent: (String verificationId, int? resendToken) {
            if (mounted) {
              setState(() => _isLoading = false);
              _navigateToOtp(verificationId);
            }
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.unexpectedError(e.toString()))),
        );
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final provider = Provider.of<LocaleProvider>(context, listen: false);
          if (provider.locale.languageCode == 'en') {
            provider.setLocale(const Locale('ar'));
          } else {
            provider.setLocale(const Locale('en'));
          }
        },
        child: const Icon(Icons.language),
      ),
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
                    const Icon(Icons.phone_android, size: 64, color: AppTheme.primaryColor),
                    const SizedBox(height: 24),
                    Text(
                      context.l10n.signInWithPhone,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.phoneVerification,
                      style: const TextStyle(fontSize: 14, color: AppTheme.textSecondaryColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: context.l10n.enterPhoneNumber,
                        prefixIcon: const Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 32),
                    _isLoading 
                      ? const Center(child: CircularProgressIndicator()) 
                      : ElevatedButton(
                          onPressed: _verifyPhone,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                          ),
                          child: Text(context.l10n.sendCode),
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
