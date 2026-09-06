import 'package:flutter/material.dart';
import '../../core/state/jury_controller.dart';
import '../../design/tokens.dart';
import '../../design/widgets/jury_widgets.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController(),
      _password = TextEditingController(),
      _name = TextEditingController();
  bool _create = false, _obscure = true;
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = JuryScope.of(context);
    return JuryPage(
      title: 'Your place in the room',
      child: Form(
        key: _form,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 28),
              const Eyebrow('A considered introduction'),
              const SizedBox(height: 12),
              Text(
                _create
                    ? 'Every perspective\nstarts somewhere.'
                    : 'Welcome\nback, juror.',
                style: JType.display(42),
              ),
              const SizedBox(height: 18),
              const Text(
                'Keep your case history, find your people, and bring your perspective to the table.',
                style: TextStyle(color: JColors.muted, height: 1.6),
              ),
              const SizedBox(height: 28),
              if (!s.cloudAvailable) ...[
                const Panel(
                  color: JColors.secondary,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.cloud_off_outlined, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Cloud accounts are not connected yet. Demo mode has the full case experience, saved on this device.',
                          style: TextStyle(fontSize: 13, height: 1.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Sign in')),
                  ButtonSegment(value: true, label: Text('Create account')),
                ],
                selected: {_create},
                onSelectionChanged: (v) => setState(() => _create = v.first),
              ),
              const SizedBox(height: 24),
              if (_create) ...[
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Display name'),
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.nickname],
                  maxLength: 30,
                  validator: (v) => (v?.trim().length ?? 0) < 2
                      ? 'Enter at least 2 characters.'
                      : null,
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email address'),
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    !RegExp(
                      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                    ).hasMatch(v?.trim() ?? '')
                    ? 'Enter a valid email address.'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _password,
                obscureText: _obscure,
                autofillHints: [
                  _create ? AutofillHints.newPassword : AutofillHints.password,
                ],
                decoration: InputDecoration(
                  labelText: 'Password',
                  helperText: _create ? 'At least 8 characters' : null,
                  suffixIcon: IconButton(
                    tooltip: _obscure ? 'Show password' : 'Hide password',
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (v) => (v?.length ?? 0) < (_create ? 8 : 1)
                    ? (_create
                          ? 'Use at least 8 characters.'
                          : 'Enter your password.')
                    : null,
              ),
              if (!_create)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: s.busy
                        ? null
                        : () async {
                            if (!RegExp(
                              r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                            ).hasMatch(_email.text.trim())) {
                              toast(context, 'Enter your email address first.');
                              return;
                            }
                            if (await s.resetPassword(_email.text.trim()) &&
                                context.mounted) {
                              toast(
                                context,
                                'Check your email for the recovery link.',
                              );
                            }
                          },
                    child: const Text('Forgot password?'),
                  ),
                ),
              const SizedBox(height: 24),
              PrimaryButton(
                _create ? 'Create your account' : 'Sign in',
                loading: s.busy,
                onPressed: () async {
                  if (!_form.currentState!.validate()) return;
                  if (await s.signIn(
                        email: _email.text.trim(),
                        password: _password.text,
                        name: _name.text.trim(),
                        create: _create,
                      ) &&
                      context.mounted) {
                    home(context);
                  }
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: s.busy
                      ? null
                      : () async {
                          if (await s.signIn(demo: true) && context.mounted) {
                            home(context);
                          }
                        },
                  child: const Text('Continue with demo profile'),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'A fictional social game. Respect other jurors, keep personal information private, and challenge ideas with care.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: JColors.muted,
                  fontSize: 12,
                  height: 1.7,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
