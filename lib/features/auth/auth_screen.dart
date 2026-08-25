import 'package:flutter/material.dart';
import '../../core/theme/live_jury_theme.dart';
import '../../core/widgets/app_frame.dart';
import '../../core/widgets/live_jury_widgets.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.onAuthenticated});
  final VoidCallback onAuthenticated;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool createAccount = false;
  bool obscurePassword = true;
  final email = TextEditingController();
  final password = TextEditingController();
  final username = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    username.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppFrame(
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: BrandMark(size: 48),
              ),
              const SizedBox(height: 48),
              Text(
                createAccount ? 'Take your seat.' : 'Welcome back.',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                createAccount
                    ? 'Create your juror profile and join thoughtful conversations.'
                    : 'Sign in to continue your casebook.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 28),
              if (createAccount) ...[
                TextField(
                  controller: username,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email address',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: password,
                obscureText: obscurePassword,
                onSubmitted: (_) => widget.onAuthenticated(),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => obscurePassword = !obscurePassword),
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
              if (!createAccount)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password reset link prepared'),
                      ),
                    ),
                    child: const Text('Forgot password?'),
                  ),
                )
              else
                const SizedBox(height: 18),
              FilledButton(
                onPressed: widget.onAuthenticated,
                child: Text(createAccount ? 'Create account' : 'Sign in'),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: widget.onAuthenticated,
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Continue with demo profile'),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    createAccount
                        ? 'Already have an account?'
                        : 'New to Live Jury?',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () =>
                        setState(() => createAccount = !createAccount),
                    child: Text(createAccount ? 'Sign in' : 'Create account'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'By continuing, you agree to the community rules and acknowledge that all cases are fictional.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
