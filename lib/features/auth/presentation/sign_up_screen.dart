import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:missao_proxima_faixa/core/l10n/app_localizations.dart';
import 'package:missao_proxima_faixa/features/auth/domain/user_role.dart';
import 'package:missao_proxima_faixa/features/auth/presentation/providers.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  bool _loading = false;
  bool _submitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _submit(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final response = await ref
          .read(authRepositoryProvider)
          .signUpParent(
            fullName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      if (!mounted) return;

      if (response.session != null) {
        context.go(UserRole.parent.routeName);
      } else {
        setState(() => _submitted = true);
      }
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } on StateError catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createParentAccount),
        leading: IconButton(
          onPressed: () => context.go('/login'),
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n.login,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _submitted
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Icon(
                              Icons.mark_email_read_outlined,
                              size: 56,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.accountCreated,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.confirmEmailHint,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => context.go('/login'),
                              child: Text(l10n.login),
                            ),
                          ],
                        )
                      : Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                l10n.parentRegistrationHint,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: _nameController,
                                textCapitalization: TextCapitalization.words,
                                decoration: InputDecoration(
                                  labelText: l10n.fullName,
                                ),
                                validator: (value) =>
                                    value == null || value.trim().length < 2
                                    ? l10n.fullNameRequired
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: l10n.email,
                                ),
                                validator: (value) =>
                                    value == null || !value.trim().contains('@')
                                    ? l10n.validEmailRequired
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: l10n.password,
                                  helperText: l10n.passwordMinimum,
                                ),
                                validator: (value) =>
                                    value == null || value.length < 8
                                    ? l10n.passwordMinimum
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _confirmationController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: l10n.confirmPassword,
                                ),
                                validator: (value) =>
                                    value != _passwordController.text
                                    ? l10n.passwordsDoNotMatch
                                    : null,
                              ),
                              const SizedBox(height: 24),
                              FilledButton(
                                onPressed: _loading
                                    ? null
                                    : () => _submit(l10n),
                                child: _loading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(l10n.createAccount),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
