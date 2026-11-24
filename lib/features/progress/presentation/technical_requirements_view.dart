import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:missao_proxima_faixa/core/l10n/app_localizations.dart';
import 'package:missao_proxima_faixa/features/passport/domain/student_passport.dart';
import 'package:missao_proxima_faixa/features/passport/presentation/providers.dart';

import '../domain/progress_models.dart';
import 'providers.dart';

class TechnicalRequirementsView extends ConsumerWidget {
  const TechnicalRequirementsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final belts = ref.watch(passportBeltsProvider);
    final requirements = ref.watch(technicalRequirementsProvider);
    return belts.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _RequirementsError(
        message: '${l10n.dashboardLoadError}: $error',
        onRetry: () => ref.invalidate(passportBeltsProvider),
      ),
      data: (beltItems) => requirements.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _RequirementsError(
          message: '${l10n.dashboardLoadError}: $error',
          onRetry: () => ref.invalidate(technicalRequirementsProvider),
        ),
        data: (items) {
          final beltsById = {for (final belt in beltItems) belt.id: belt};
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: () =>
                        context.go('/admin/technical-requirements/new'),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.createTechnicalRequirement),
                  ),
                ),
              ),
              Expanded(
                child: beltItems.isEmpty
                    ? Center(child: Text(l10n.noBeltsAvailable))
                    : items.isEmpty
                    ? Center(child: Text(l10n.noTechnicalRequirements))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) => _RequirementCard(
                          item: items[index],
                          belt: beltsById[items[index].beltId],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RequirementCard extends StatelessWidget {
  const _RequirementCard({required this.item, required this.belt});

  final TechnicalRequirement item;
  final PassportBelt? belt;

  @override
  Widget build(BuildContext context) {
    final isSpanish = Localizations.localeOf(context).languageCode == 'es';
    final name = isSpanish ? item.nameEs : item.namePt;
    final description = isSpanish ? item.descriptionEs : item.descriptionPt;
    final beltName = belt == null
        ? ''
        : isSpanish
        ? belt!.nameEs
        : belt!.namePt;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.sports_martial_arts),
        title: Text(name),
        subtitle: Text(
          [
            if (beltName.isNotEmpty) beltName,
            if (description != null && description.isNotEmpty) description,
          ].join(' • '),
        ),
      ),
    );
  }
}

class CreateTechnicalRequirementScreen extends ConsumerStatefulWidget {
  const CreateTechnicalRequirementScreen({super.key});

  @override
  ConsumerState<CreateTechnicalRequirementScreen> createState() =>
      _CreateTechnicalRequirementScreenState();
}

class _CreateTechnicalRequirementScreenState
    extends ConsumerState<CreateTechnicalRequirementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namePtController = TextEditingController();
  final _nameEsController = TextEditingController();
  final _descriptionPtController = TextEditingController();
  final _descriptionEsController = TextEditingController();
  String? _beltId;
  bool _saving = false;

  @override
  void dispose() {
    _namePtController.dispose();
    _nameEsController.dispose();
    _descriptionPtController.dispose();
    _descriptionEsController.dispose();
    super.dispose();
  }

  Future<void> _save({required String defaultBeltId}) async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    final beltId = _beltId ?? defaultBeltId;
    setState(() => _saving = true);
    try {
      await ref
          .read(progressRepositoryProvider)
          .createTechnicalRequirement(
            beltId: beltId,
            namePt: _namePtController.text,
            nameEs: _nameEsController.text,
            descriptionPt: _descriptionPtController.text,
            descriptionEs: _descriptionEsController.text,
          );
      ref.invalidate(technicalRequirementsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.technicalRequirementCreated)));
      context.go('/admin');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.technicalRequirementCreateFailed}: $error'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final belts = ref.watch(passportBeltsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.createTechnicalRequirement)),
      body: belts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('${l10n.dashboardLoadError}: $error')),
        data: (items) {
          if (items.isEmpty) return Center(child: Text(l10n.noBeltsAvailable));
          final selectedBeltId = items.any((belt) => belt.id == _beltId)
              ? _beltId!
              : items.first.id;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedBeltId,
                      decoration: InputDecoration(labelText: l10n.selectBelt),
                      items: items
                          .map(
                            (belt) => DropdownMenuItem(
                              value: belt.id,
                              child: Text(
                                Localizations.localeOf(context).languageCode ==
                                        'es'
                                    ? belt.nameEs
                                    : belt.namePt,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _beltId = value),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _namePtController,
                      decoration: InputDecoration(
                        labelText: l10n.technicalRequirementNamePt,
                      ),
                      validator: _requiredValidator,
                      maxLength: 120,
                    ),
                    TextFormField(
                      controller: _nameEsController,
                      decoration: InputDecoration(
                        labelText: l10n.technicalRequirementNameEs,
                      ),
                      validator: _requiredValidator,
                      maxLength: 120,
                    ),
                    TextFormField(
                      controller: _descriptionPtController,
                      decoration: InputDecoration(
                        labelText: l10n.technicalRequirementDescriptionPt,
                      ),
                      maxLength: 500,
                    ),
                    TextFormField(
                      controller: _descriptionEsController,
                      decoration: InputDecoration(
                        labelText: l10n.technicalRequirementDescriptionEs,
                      ),
                      maxLength: 500,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _saving
                          ? null
                          : () => _save(defaultBeltId: selectedBeltId),
                      child: _saving
                          ? const CircularProgressIndicator()
                          : Text(l10n.save),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String? _requiredValidator(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.length < 2) {
      return AppLocalizations.of(context)!.technicalRequirementNameRequired;
    }
    return null;
  }
}

class _RequirementsError extends StatelessWidget {
  const _RequirementsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          TextButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}
