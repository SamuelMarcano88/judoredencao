import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:missao_proxima_faixa/core/l10n/app_localizations.dart';
import 'package:missao_proxima_faixa/features/passport/domain/student_passport.dart';
import 'package:missao_proxima_faixa/features/passport/presentation/providers.dart';
import 'package:missao_proxima_faixa/features/progress/domain/progress_models.dart';
import 'package:missao_proxima_faixa/features/progress/presentation/providers.dart';
import 'package:missao_proxima_faixa/features/students/domain/student_record.dart';
import 'package:missao_proxima_faixa/features/students/presentation/providers.dart';
import 'package:missao_proxima_faixa/features/students/presentation/student_dashboard_views.dart';
import 'package:missao_proxima_faixa/features/passport/presentation/student_passport_view.dart';

void main() {
  testWidgets('parent dashboard summarizes each child progress', (
    WidgetTester tester,
  ) async {
    const studentId = 'student-id';
    const cycleId = 'cycle-id';
    const beltId = 'belt-id';
    final technicalRequest = (
      studentId: studentId,
      cycleId: cycleId,
      beltId: beltId,
    );
    final passport = StudentPassport(
      studentId: studentId,
      studentName: 'João Silva',
      currentBeltNamePt: 'Amarela',
      currentBeltNameEs: 'Amarillo',
      currentBeltColor: '#FFFF00',
      cycle: PassportCycle(
        id: cycleId,
        name: 'Ciclo inicial',
        startDate: DateTime(2026, 1, 1),
        endDate: null,
        nextBeltId: beltId,
        nextBeltNamePt: 'Laranja',
        nextBeltNameEs: 'Naranja',
        items: const [
          PassportChecklistItem(
            id: 'done',
            namePt: 'Cumprimentar',
            nameEs: 'Saludar',
            descriptionPt: null,
            descriptionEs: null,
            required: true,
            isCompleted: true,
          ),
          PassportChecklistItem(
            id: 'pending',
            namePt: 'Amarrar a faixa',
            nameEs: 'Atar el cinturón',
            descriptionPt: null,
            descriptionEs: null,
            required: true,
            isCompleted: false,
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studentsProvider.overrideWith(
            (ref) async => [
              StudentRecord(
                id: studentId,
                fullName: 'João Silva',
                birthDate: null,
                username: 'joao',
              ),
            ],
          ),
          studentPassportProvider(
            studentId,
          ).overrideWith((ref) async => passport),
          attendanceHistoryProvider(studentId).overrideWith(
            (ref) async => [
              AttendanceRecord(
                cycleId: cycleId,
                classDate: DateTime(2026, 1, 1),
                status: AttendanceStatus.present,
              ),
              AttendanceRecord(
                cycleId: cycleId,
                classDate: DateTime(2026, 1, 8),
                status: AttendanceStatus.absent,
              ),
            ],
          ),
          technicalProgressProvider(technicalRequest).overrideWith(
            (ref) async => [
              TechnicalRequirementProgress(
                id: 'requirement-1',
                beltId: beltId,
                namePt: 'Queda',
                nameEs: 'Caída',
                descriptionPt: null,
                descriptionEs: null,
                status: TechnicalEvaluationStatus.achieved,
                observation: null,
              ),
              TechnicalRequirementProgress(
                id: 'requirement-2',
                beltId: beltId,
                namePt: 'Imobilização',
                nameEs: 'Inmovilización',
                descriptionPt: null,
                descriptionEs: null,
                status: TechnicalEvaluationStatus.developing,
                observation: null,
              ),
            ],
          ),
        ],
        child: MaterialApp(
          locale: const Locale('pt'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: ParentDashboardView()),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('João Silva'), findsOneWidget);
    expect(find.text('Resumo do progresso'), findsOneWidget);
    expect(find.text('Ciclo inicial'), findsOneWidget);
    expect(find.text('1 de 2 atividades obrigatórias'), findsOneWidget);
    expect(find.textContaining('Frequência: 50%'), findsOneWidget);
    expect(find.text('1 de 2 requisitos técnicos concluídos'), findsOneWidget);
  });

  testWidgets('student dashboard shows overview and editable checklist', (
    WidgetTester tester,
  ) async {
    const studentId = 'student-dashboard-id';
    final passport = StudentPassport(
      studentId: studentId,
      studentName: 'Maria Silva',
      currentBeltNamePt: 'Amarela',
      currentBeltNameEs: 'Amarillo',
      currentBeltColor: '#FFFF00',
      cycle: PassportCycle(
        id: 'student-cycle',
        name: 'Ciclo da Maria',
        startDate: DateTime(2026, 1, 1),
        endDate: null,
        nextBeltNamePt: null,
        nextBeltNameEs: null,
        items: const [
          PassportChecklistItem(
            id: 'pending',
            namePt: 'Amarrar a faixa',
            nameEs: 'Atar el cinturón',
            descriptionPt: null,
            descriptionEs: null,
            required: true,
            isCompleted: false,
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studentPassportProvider(
            studentId,
          ).overrideWith((ref) async => passport),
          attendanceHistoryProvider(
            studentId,
          ).overrideWith((ref) async => const []),
        ],
        child: MaterialApp(
          locale: const Locale('pt'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: StudentPassportView(
              studentId: studentId,
              allowCompletion: true,
              showProgressOverview: true,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Resumo do progresso'), findsOneWidget);
    expect(find.text('Ciclo da Maria'), findsWidgets);
    final checklist = tester.widget<CheckboxListTile>(
      find.byType(CheckboxListTile),
    );
    expect(checklist.onChanged, isNotNull);
  });
}
