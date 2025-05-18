import 'package:ealapp/providers/top_level_provier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // TODO: Add PocketBase instance (e.g., via Riverpod provider)

  Future<void> _loginWithEmail() async {
    final pbInstance = ref.read(pocketbaseProvider);
    if (!_formKey.currentState!.validate()) {
      return; // Form is not valid
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Display loading indicator if needed
    // setState(() => _isLoading = true);

    try {
      print('Attempting login with Email: $email');
      // TODO: Replace with actual PocketBase authentication call
      // Example using a hypothetical PocketBase instance 'pb':
      await pbInstance.collection('users').authWithPassword(email, password);

      print('Login successful');

      // TODO: Navigate to the next screen upon successful login
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login Successful')));
        // Example: Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      print('Login failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Failed: ${e.toString()}')),
        );
      }
    } finally {
      // Hide loading indicator if shown
      // if (mounted) {
      //   setState(() => _isLoading = false);
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  // Basic email validation
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Process login logic here
                    final email = _emailController.text;
                    final password = _passwordController.text;
                    print(
                      'Login attempt with Email: $email, Password: $password',
                    );

                    _loginWithEmail();

                    // TODO: Implement actual login logic (e.g., call an API)
                  }
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 12),
              // TextButton(
              //   onPressed: () {
              //     // Navigate to registration screen
              //     print('Navigate to Register Screen');
              //     // TODO: Implement navigation to the registration view
              //     // Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterView()));
              //   },
              //   child: const Text('Don\'t have an account? Register'),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
