import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:missao_proxima_faixa/core/config/app_environment.dart';
import 'package:missao_proxima_faixa/core/l10n/app_localizations.dart';
import 'package:missao_proxima_faixa/features/auth/domain/user_role.dart';
import 'providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      final role = await repository.getCurrentRole();
      if (!mounted) return;
      if (role == UserRole.unknown) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.profileNotConfigured)));
        return;
      }
      context.go(role.routeName);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.invalidCredentials)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle(AppLocalizations l10n) async {
    setState(() => _loading = true);
    try {
      final launched = await ref
          .read(authRepositoryProvider)
          .signInWithGoogle(redirectTo: Uri.base.origin);
      if (!launched && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.googleSignInUnavailable)));
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.appTitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 24),
                        if (!AppEnvironment.isSupabaseConfigured) ...[
                          Text(
                            l10n.configurationRequired,
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.configurationHint,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                        ],
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(labelText: l10n.email),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? l10n.email
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(labelText: l10n.password),
                          validator: (value) => value == null || value.isEmpty
                              ? l10n.password
                              : null,
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed:
                              !_loading && AppEnvironment.isSupabaseConfigured
                              ? () => _submit(l10n)
                              : null,
                          child: _loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(l10n.login),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed:
                              !_loading && AppEnvironment.isSupabaseConfigured
                              ? () => _signInWithGoogle(l10n)
                              : null,
                          icon: const Icon(Icons.g_mobiledata),
                          label: Text(l10n.continueWithGoogle),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: AppEnvironment.isSupabaseConfigured
                              ? () => context.go('/cadastro')
                              : null,
                          child: Text(l10n.createParentAccount),
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
