import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:missao_proxima_faixa/core/l10n/app_localizations.dart';
import 'package:missao_proxima_faixa/features/auth/domain/user_role.dart';
import 'package:missao_proxima_faixa/features/auth/presentation/providers.dart';
import 'package:missao_proxima_faixa/features/students/domain/parent_record.dart';
import 'package:missao_proxima_faixa/features/students/presentation/providers.dart';

class CreateStudentScreen extends ConsumerStatefulWidget {
  const CreateStudentScreen({super.key});

  @override
  ConsumerState<CreateStudentScreen> createState() =>
      _CreateStudentScreenState();
}

class _CreateStudentScreenState extends ConsumerState<CreateStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _relationshipController = TextEditingController();
  UserRole? _role;
  List<ParentRecord> _parents = [];
  DateTime? _birthDate;
  String? _parentUserId;
  Object? _loadError;
  bool _saving = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  Future<void> _loadFormData() async {
    try {
      final role = await ref.read(authRepositoryProvider).getCurrentRole();
      if (role != UserRole.admin && role != UserRole.parent) {
        throw StateError(
          'Only admins and parents can create student accounts.',
        );
      }
      final parents = role == UserRole.admin
          ? await ref.read(studentRepositoryProvider).fetchParents()
          : <ParentRecord>[];
      if (!mounted) return;
      setState(() {
        _role = role;
        _parents = parents;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error;
        _loading = false;
      });
    }
  }

  Future<void> _selectBirthDate() async {
    final today = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate:
          _birthDate ?? DateTime(today.year - 8, today.month, today.day),
      firstDate: DateTime(1900),
      lastDate: today,
    );
    if (date != null) setState(() => _birthDate = date);
  }

  Future<void> _submit(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;
    if (_role == UserRole.admin && _parentUserId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.selectParent)));
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(studentRepositoryProvider)
          .createStudent(
            fullName: _nameController.text,
            username: _usernameController.text,
            password: _passwordController.text,
            birthDate: _birthDate,
            relationship: _relationshipController.text,
            parentUserId: _parentUserId,
          );
      ref.invalidate(studentsProvider);
      if (!mounted) return;
      context.go(_role == UserRole.admin ? '/admin' : '/responsavel');
    } on FunctionException catch (error) {
      if (!mounted) return;
      final details = error.details;
      final serverMessage = details is Map && details['error'] is String
          ? details['error'] as String
          : null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            serverMessage ?? '${l10n.studentCreationFailed} (${error.status})',
          ),
        ),
      );
    } on PostgrestException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.studentCreationFailed}: ${error.message}'),
        ),
      );
    } on StateError catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _dateLabel(AppLocalizations l10n) {
    final date = _birthDate;
    if (date == null) return l10n.birthDateOptional;
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addStudent)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _loadError != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('${l10n.dashboardLoadError}: $_loadError'),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                l10n.studentDetails,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _nameController,
                                textCapitalization: TextCapitalization.words,
                                decoration: InputDecoration(
                                  labelText: l10n.studentName,
                                ),
                                validator: (value) =>
                                    value == null || value.trim().length < 2
                                    ? l10n.studentNameRequired
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: _selectBirthDate,
                                icon: const Icon(Icons.calendar_month),
                                label: Text(_dateLabel(l10n)),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                l10n.studentAccessDetails,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _usernameController,
                                autocorrect: false,
                                decoration: InputDecoration(
                                  labelText: l10n.username,
                                  helperText: l10n.usernameRules,
                                ),
                                validator: (value) =>
                                    value == null ||
                                        !RegExp(
                                          r'^[a-zA-Z0-9][a-zA-Z0-9._-]{2,29}$',
                                        ).hasMatch(value.trim())
                                    ? l10n.usernameRules
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: l10n.studentPassword,
                                  helperText: l10n.passwordMinimum,
                                ),
                                validator: (value) =>
                                    value == null || value.length < 8
                                    ? l10n.passwordMinimum
                                    : null,
                              ),
                              if (_role == UserRole.parent) ...[
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _relationshipController,
                                  decoration: InputDecoration(
                                    labelText: l10n.relationshipOptional,
                                  ),
                                ),
                              ],
                              if (_role == UserRole.admin) ...[
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  initialValue: _parentUserId,
                                  decoration: InputDecoration(
                                    labelText: l10n.parent,
                                  ),
                                  items: _parents
                                      .map(
                                        (parent) => DropdownMenuItem(
                                          value: parent.id,
                                          child: Text(parent.fullName),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: _parents.isEmpty
                                      ? null
                                      : (value) => setState(
                                          () => _parentUserId = value,
                                        ),
                                ),
                                if (_parents.isEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(l10n.noParentsForAssignment),
                                ],
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _relationshipController,
                                  decoration: InputDecoration(
                                    labelText: l10n.relationshipOptional,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                              FilledButton(
                                onPressed:
                                    _saving ||
                                        (_role == UserRole.admin &&
                                            _parents.isEmpty)
                                    ? null
                                    : () => _submit(l10n),
                                child: _saving
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(l10n.createStudent),
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
