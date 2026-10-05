import 'package:flutter/material.dart';
import '../backend/core/local_accounts.dart';
import 'game_state.dart';
import 'operations_pages.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onSignedIn;
  const LoginPage({super.key, required this.onSignedIn});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final username = TextEditingController();
  final password = TextEditingController();
  final confirmation = TextEditingController();
  bool createAccount = true;
  bool busy = false;
  String? error;

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    confirmation.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (busy) return;
    if (createAccount && password.text != confirmation.text) {
      setState(() => error = 'Passwords do not match.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (createAccount) {
        await truckGameState.accounts.register(username.text, password.text);
      } else {
        await truckGameState.accounts.signIn(username.text, password.text);
      }
      password.clear();
      confirmation.clear();
      await truckGameState.selectSignedInAccount();
      if (mounted) widget.onSignedIn();
    } on AccountException catch (e) {
      if (mounted) setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
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
                  const Text(
                    'TRUCK MANAGER',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    createAccount ? 'CREATE ACCOUNT' : 'SIGN IN',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: username,
                    enabled: !busy,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      helperText:
                          'Choose your own player name (3–32 characters)',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: password,
                    enabled: !busy,
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    onSubmitted: (_) {
                      if (!createAccount) submit();
                    },
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      helperText: '12–128 characters',
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  if (createAccount) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmation,
                      enabled: !busy,
                      obscureText: true,
                      autocorrect: false,
                      enableSuggestions: false,
                      onSubmitted: (_) => submit(),
                      decoration: const InputDecoration(
                        labelText: 'Confirm password',
                      ),
                    ),
                  ],
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        error!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: busy ? null : submit,
                    icon: const Icon(Icons.login),
                    label: Text(
                      busy
                          ? 'PLEASE WAIT…'
                          : createAccount
                          ? 'CREATE ACCOUNT & CONTINUE'
                          : 'SIGN IN',
                    ),
                  ),
                  TextButton(
                    onPressed: busy
                        ? null
                        : () => setState(() {
                            createAccount = !createAccount;
                            error = null;
                            password.clear();
                            confirmation.clear();
                          }),
                    child: Text(
                      createAccount
                          ? 'Already have an account? Sign in'
                          : 'New player? Create an account',
                    ),
                  ),
                  const Divider(),
                  const Text(
                    'Local alpha: accounts and progress last only while this app is open. Closing the app clears them.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.white60),
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
