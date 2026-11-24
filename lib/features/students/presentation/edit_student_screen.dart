import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:missao_proxima_faixa/core/l10n/app_localizations.dart';
import 'package:missao_proxima_faixa/features/auth/domain/user_role.dart';
import 'package:missao_proxima_faixa/features/auth/presentation/providers.dart';
import 'package:missao_proxima_faixa/features/students/presentation/providers.dart';

class EditStudentScreen extends ConsumerStatefulWidget {
  const EditStudentScreen({super.key, required this.studentId});

  final String studentId;

  @override
  ConsumerState<EditStudentScreen> createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends ConsumerState<EditStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _birthDate;
  Object? _loadError;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadStudent();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadStudent() async {
    try {
      final role = await ref.read(authRepositoryProvider).getCurrentRole();
      if (role != UserRole.admin) {
        throw StateError('Only admins can edit student profiles.');
      }
      final student = await ref
          .read(studentRepositoryProvider)
          .fetchStudent(widget.studentId);
      if (!mounted) return;
      setState(() {
        _nameController.text = student.fullName;
        _birthDate = student.birthDate;
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

  Future<void> _save(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(studentRepositoryProvider)
          .updateStudent(
            studentId: widget.studentId,
            fullName: _nameController.text,
            birthDate: _birthDate,
          );
      ref.invalidate(studentsProvider);
      if (!mounted) return;
      context.go('/admin');
    } on PostgrestException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.studentUpdateFailed}: ${error.message}'),
        ),
      );
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
      appBar: AppBar(title: Text(l10n.editStudent)),
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
                              FilledButton(
                                onPressed: _saving ? null : () => _save(l10n),
                                child: _saving
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(l10n.save),
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
