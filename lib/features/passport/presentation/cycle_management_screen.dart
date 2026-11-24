import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:missao_proxima_faixa/core/l10n/app_localizations.dart';
import 'package:missao_proxima_faixa/features/students/domain/student_record.dart';
import 'package:missao_proxima_faixa/features/students/presentation/providers.dart';

import '../domain/student_passport.dart';
import 'providers.dart';

class CycleListView extends ConsumerWidget {
  const CycleListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cycles = ref.watch(trainingCyclesProvider);

    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: FilledButton.icon(
              onPressed: () => context.push('/admin/cycles/new'),
              icon: const Icon(Icons.add),
              label: Text(l10n.createCycle),
            ),
          ),
        ),
        Expanded(
          child: cycles.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${l10n.dashboardLoadError}: $error',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => ref.invalidate(trainingCyclesProvider),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
            data: (items) => items.isEmpty
                ? Center(child: Text(l10n.noCycles))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final cycle = items[index];
                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.autorenew),
                          ),
                          title: Text(cycle.name),
                          subtitle: Text(
                            '${_formatDate(cycle.startDate)}'
                            '${cycle.endDate == null ? '' : ' – ${_formatDate(cycle.endDate!)}'}'
                            ' • ${_localizedStatus(cycle.status, l10n)}',
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _localizedStatus(String status, AppLocalizations l10n) {
    return switch (status) {
      'active' => l10n.cycleStatusActive,
      'planned' => l10n.cycleStatusPlanned,
      'completed' => l10n.cycleStatusCompleted,
      _ => status,
    };
  }
}

class CreateCycleScreen extends ConsumerStatefulWidget {
  const CreateCycleScreen({super.key});

  @override
  ConsumerState<CreateCycleScreen> createState() => _CreateCycleScreenState();
}

class _CreateCycleScreenState extends ConsumerState<CreateCycleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _activities = <_ActivityDraft>[_ActivityDraft()];
  final Set<String> _selectedStudentIds = {};
  List<StudentRecord> _students = [];
  List<PassportBelt> _belts = [];
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  String? _currentBeltId;
  String? _nextBeltId;
  Object? _loadError;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final activity in _activities) {
      activity.dispose();
    }
    super.dispose();
  }

  Future<void> _loadFormData() async {
    try {
      final results = await Future.wait([
        ref.read(studentRepositoryProvider).fetchStudents(),
        ref.read(passportRepositoryProvider).fetchBelts(),
      ]);
      if (!mounted) return;
      setState(() {
        _students = results[0] as List<StudentRecord>;
        _belts = results[1] as List<PassportBelt>;
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

  Future<void> _selectDate({required bool isStartDate}) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : (_endDate ?? _startDate),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selectedDate == null || !mounted) return;
    setState(() {
      if (isStartDate) {
        _startDate = selectedDate;
      } else {
        _endDate = selectedDate;
      }
    });
  }

  Future<void> _submit(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStudentIds.isEmpty) {
      _showError(l10n.selectParticipantsHint);
      return;
    }
    if (_endDate != null && _endDate!.isBefore(_startDate)) {
      _showError(l10n.cycleDateRangeInvalid);
      return;
    }
    for (final activity in _activities) {
      final categoryPt = activity.categoryPtController.text.trim();
      final categoryEs = activity.categoryEsController.text.trim();
      if (categoryPt.isEmpty != categoryEs.isEmpty) {
        _showError(l10n.categoryNamesBothRequired);
        return;
      }
    }

    setState(() => _saving = true);
    try {
      await ref
          .read(passportRepositoryProvider)
          .createCycle(
            name: _nameController.text,
            startDate: _startDate,
            endDate: _endDate,
            currentBeltId: _currentBeltId,
            nextBeltId: _nextBeltId,
            studentIds: _selectedStudentIds.toList(),
            activities: _activities
                .map(
                  (activity) => {
                    'namePt': activity.namePtController.text.trim(),
                    'nameEs': activity.nameEsController.text.trim(),
                    'required': activity.required,
                    'categoryPt':
                        activity.categoryPtController.text.trim().isEmpty
                        ? null
                        : activity.categoryPtController.text.trim(),
                    'categoryEs':
                        activity.categoryEsController.text.trim().isEmpty
                        ? null
                        : activity.categoryEsController.text.trim(),
                  },
                )
                .toList(),
          );
      ref.invalidate(trainingCyclesProvider);
      if (!mounted) return;
      context.pop();
    } on PostgrestException catch (error) {
      if (mounted) _showError('${l10n.createCycleFailed}: ${error.message}');
    } catch (error) {
      if (mounted) _showError('${l10n.createCycleFailed}: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSpanish = Localizations.localeOf(context).languageCode == 'es';
    return Scaffold(
      appBar: AppBar(title: Text(l10n.createCycle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _loadError != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        '${l10n.dashboardLoadError}: $_loadError',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : _students.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        l10n.noStudentsAvailable,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        Text(
                          l10n.createCycleDetails,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(labelText: l10n.cycleName),
                          validator: (value) =>
                              value == null || value.trim().length < 2
                              ? l10n.cycleNameRequired
                              : null,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => _selectDate(isStartDate: true),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            '${l10n.startDate}: ${_formatDate(_startDate)}',
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () => _selectDate(isStartDate: false),
                          icon: const Icon(Icons.event),
                          label: Text(
                            _endDate == null
                                ? l10n.endDateOptional
                                : '${l10n.endDateOptional}: ${_formatDate(_endDate!)}',
                          ),
                        ),
                        if (_endDate != null)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => setState(() => _endDate = null),
                            child: Text(l10n.clearDate),
                            ),
                          ),
                        if (_belts.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _buildBeltDropdown(
                            label: l10n.currentBelt,
                            selectedId: _currentBeltId,
                            onChanged: (value) =>
                                setState(() => _currentBeltId = value),
                            isSpanish: isSpanish,
                            l10n: l10n,
                          ),
                          const SizedBox(height: 12),
                          _buildBeltDropdown(
                            label: l10n.nextBelt,
                            selectedId: _nextBeltId,
                            onChanged: (value) =>
                                setState(() => _nextBeltId = value),
                            isSpanish: isSpanish,
                            l10n: l10n,
                          ),
                        ],
                        const SizedBox(height: 24),
                        Text(
                          l10n.cycleParticipants,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Card(
                          child: Column(
                            children: _students
                                .map(
                                  (student) => CheckboxListTile(
                                    value: _selectedStudentIds.contains(
                                      student.id,
                                    ),
                                    title: Text(student.fullName),
                                    onChanged: _saving
                                        ? null
                                        : (selected) {
                                            setState(() {
                                              if (selected == true) {
                                                _selectedStudentIds.add(
                                                  student.id,
                                                );
                                              } else {
                                                _selectedStudentIds.remove(
                                                  student.id,
                                                );
                                              }
                                            });
                                          },
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.checklistActivities,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            IconButton(
                              tooltip: l10n.addActivity,
                              onPressed: _saving
                                  ? null
                                  : () => setState(
                                      () => _activities.add(_ActivityDraft()),
                                    ),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ..._activities.asMap().entries.map((entry) {
                          final index = entry.key;
                          final activity = entry.value;
                          return Card(
                            key: ObjectKey(activity),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  if (_activities.length > 1)
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: IconButton(
                                        tooltip: l10n.removeActivity,
                                        onPressed: _saving
                                            ? null
                                            : () => setState(() {
                                                _activities.removeAt(index);
                                                activity.dispose();
                                              }),
                                        icon: const Icon(Icons.remove_circle),
                                      ),
                                    ),
                                  TextFormField(
                                    controller: activity.namePtController,
                                    decoration: InputDecoration(
                                      labelText: l10n.activityNamePortuguese,
                                    ),
                                    validator: _validateActivityName(l10n),
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: activity.nameEsController,
                                    decoration: InputDecoration(
                                      labelText: l10n.activityNameSpanish,
                                    ),
                                    validator: _validateActivityName(l10n),
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: activity.categoryPtController,
                                    decoration: InputDecoration(
                                      labelText:
                                          l10n.categoryNamePortugueseOptional,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: activity.categoryEsController,
                                    decoration: InputDecoration(
                                      labelText:
                                          l10n.categoryNameSpanishOptional,
                                    ),
                                  ),
                                  CheckboxListTile(
                                    value: activity.required,
                                    title: Text(l10n.requiredActivity),
                                    onChanged: _saving
                                        ? null
                                        : (value) => setState(
                                            () => activity.required =
                                                value ?? true,
                                          ),
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _saving ? null : () => _submit(l10n),
                          child: _saving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(l10n.createCycle),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  String? Function(String?) _validateActivityName(AppLocalizations l10n) {
    return (value) => value == null || value.trim().length < 2
        ? l10n.activityNameRequired
        : null;
  }

  Widget _buildBeltDropdown({
    required String label,
    required String? selectedId,
    required ValueChanged<String?> onChanged,
    required bool isSpanish,
    required AppLocalizations l10n,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: selectedId ?? '',
      decoration: InputDecoration(labelText: label),
      items: [
        DropdownMenuItem(value: '', child: Text(l10n.noBeltSelected)),
        ..._belts.map(
          (belt) => DropdownMenuItem(
            value: belt.id,
            child: Text(isSpanish ? belt.nameEs : belt.namePt),
          ),
        ),
      ],
      onChanged: _saving
          ? null
          : (value) => onChanged(value == null || value.isEmpty ? null : value),
    );
  }
}

class _ActivityDraft {
  final namePtController = TextEditingController();
  final nameEsController = TextEditingController();
  final categoryPtController = TextEditingController();
  final categoryEsController = TextEditingController();
  bool required = true;

  void dispose() {
    namePtController.dispose();
    nameEsController.dispose();
    categoryPtController.dispose();
    categoryEsController.dispose();
  }
}
