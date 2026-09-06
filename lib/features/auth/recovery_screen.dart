import 'package:flutter/material.dart';
import '../../core/state/jury_controller.dart';
import '../../design/tokens.dart';
import '../../design/widgets/jury_widgets.dart';

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({super.key});
  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  bool _obscure = true;
  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = JuryScope.of(context);
    return JuryPage(
      title: 'A fresh start',
      back: false,
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            const Icon(
              Icons.lock_reset_rounded,
              size: 42,
              color: JColors.brand,
            ),
            const SizedBox(height: 24),
            Text('Make your account\nyours again.', style: JType.display(36)),
            const SizedBox(height: 16),
            const Text(
              'Choose a new password, then sign in to return to your seat.',
              style: TextStyle(color: JColors.muted, height: 1.6),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _password,
              obscureText: _obscure,
              autofillHints: const [AutofillHints.newPassword],
              decoration: InputDecoration(
                labelText: 'New password',
                helperText: 'At least 8 characters',
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
              validator: (v) =>
                  (v?.length ?? 0) < 8 ? 'Use at least 8 characters.' : null,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              'Save new password',
              loading: s.busy,
              icon: Icons.check_rounded,
              onPressed: () async {
                if (!_form.currentState!.validate()) return;
                if (await s.updatePassword(_password.text) && context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/auth', (_) => false);
                  toast(
                    context,
                    'Password updated. Sign in with your new password.',
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
