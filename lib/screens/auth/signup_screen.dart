import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:green_share/core/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:green_share/main.dart';
import 'package:provider/provider.dart';
import 'package:green_share/providers/locale_provider.dart';
import 'package:green_share/screens/auth/otp_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _crController = TextEditingController();
  
  String _selectedRole = 'User';
  final List<String> _roles = ['User', 'Charity'];
  
  bool _isLoading = false;

  void _navigateToOtp(String verificationId, String phone, [ConfirmationResult? webResult]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpScreen(
          phoneNumber: phone,
          verificationId: verificationId,
          webConfirmationResult: webResult,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          role: _selectedRole,
          crNumber: _selectedRole == 'Charity' ? _crController.text.trim() : null,
        ),
      ),
    );
  }

  Future<void> _signup() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    String phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final crNumber = _crController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.pleaseFillAllFields)),
      );
      return;
    }

    final jordanPhoneRegExp = RegExp(r'^(?:\+962|0)?7[789]\d{7}$');
    if (!jordanPhoneRegExp.hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.invalidJordanPhoneNumber)),
      );
      return;
    }

    if (phone.startsWith('07')) {
      phone = '+962${phone.substring(1)}';
    } else if (phone.startsWith('7')) {
      phone = '+962$phone';
    }

    if (email.isNotEmpty && password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.pleaseEnterEmailPass)),
      );
      return;
    }

    if (_selectedRole == 'Charity' && crNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.pleaseFillAllFields)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (kIsWeb) {
        ConfirmationResult result = await FirebaseAuth.instance.signInWithPhoneNumber(phone);
        if (mounted) {
          setState(() => _isLoading = false);
          _navigateToOtp(result.verificationId, phone, result);
        }
      } else {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phone,
          verificationCompleted: (PhoneAuthCredential credential) async {
            // Usually handled in OTP screen or automatic, keep simple
          },
          verificationFailed: (FirebaseAuthException e) {
            if (mounted) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.message ?? context.l10n.signupFailed)),
              );
            }
          },
          codeSent: (String verificationId, int? resendToken) {
            if (mounted) {
              setState(() => _isLoading = false);
              _navigateToOtp(verificationId, phone);
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
                    const Icon(Icons.person_add_outlined, size: 64, color: AppTheme.primaryColor),
                    const SizedBox(height: 24),
                    Text(
                      context.l10n.createAnAccount,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.joinCommunityToday,
                      style: const TextStyle(fontSize: 14, color: AppTheme.textSecondaryColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              labelText: context.l10n.firstName,
                              prefixIcon: const Icon(Icons.person_outline),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              labelText: context.l10n.lastName,
                              prefixIcon: const Icon(Icons.person_outline),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: context.l10n.enterPhoneNumber,
                        prefixIcon: const Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: '${context.l10n.email} (Optional)',
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: context.l10n.password,
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedRole,
                      decoration: InputDecoration(
                        labelText: context.l10n.role,
                        prefixIcon: const Icon(Icons.group_outlined),
                      ),
                      items: _roles.map((role) {
                        return DropdownMenuItem(value: role, child: Text(
                          role == 'User' ? context.l10n.user : 
                          context.l10n.charity
                        ));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedRole = val);
                        }
                      },
                    ),
                    if (_selectedRole == 'Charity') ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: _crController,
                        decoration: InputDecoration(
                          labelText: context.l10n.commercialRegistration,
                          prefixIcon: const Icon(Icons.business),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    _isLoading 
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _signup,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                          ),
                          child: Text(context.l10n.signUp),
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
