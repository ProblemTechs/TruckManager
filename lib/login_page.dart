import 'package:flutter/material.dart';
import 'operations_pages.dart';

class LoginPage extends StatefulWidget {
  final void Function(String playerName) onSignedIn;
  const LoginPage({super.key, required this.onSignedIn});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool createAccount = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void submit() {
    if (email.text.trim().isEmpty || password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter an email and password.')),
      );
      return;
    }
    final raw = email.text.trim().split('@').first;
    widget.onSignedIn(raw.isEmpty ? 'Player' : raw);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF071522), Color(0xFF123B58)],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(Icons.local_shipping, size: 68, color: green),
                        const Text('TRUCK MANAGER', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
                        const Text('BUILD • DISPATCH • GROW', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60, letterSpacing: 2)),
                        const SizedBox(height: 28),
                        Text(createAccount ? 'CREATE ACCOUNT' : 'SIGN IN', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 14),
                        TextField(controller: email, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email))),
                        const SizedBox(height: 12),
                        TextField(controller: password, obscureText: true, onSubmitted: (_) => submit(), decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock))),
                        const SizedBox(height: 18),
                        FilledButton.icon(onPressed: submit, icon: const Icon(Icons.login), label: Text(createAccount ? 'CREATE ACCOUNT & CONTINUE' : 'SIGN IN')),
                        TextButton(onPressed: () => setState(() => createAccount = !createAccount), child: Text(createAccount ? 'Already have an account? Sign in' : 'New player? Create an account')),
                        const Divider(),
                        const Text('Playable alpha: authentication is local for now. Cloud account authentication will replace this before public release.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.white54)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
