import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:missao_proxima_faixa/core/l10n/app_localizations.dart';
import 'package:missao_proxima_faixa/features/auth/presentation/login_screen.dart';
import 'package:missao_proxima_faixa/features/auth/presentation/sign_up_screen.dart';
import 'package:missao_proxima_faixa/features/passport/domain/student_passport.dart';
import 'package:missao_proxima_faixa/features/passport/presentation/providers.dart';
import 'package:missao_proxima_faixa/features/passport/presentation/student_passport_view.dart';
import 'package:missao_proxima_faixa/features/students/domain/student_record.dart';
import 'package:missao_proxima_faixa/features/students/presentation/providers.dart';
import 'package:missao_proxima_faixa/features/students/presentation/student_dashboard_views.dart';

void main() {
  testWidgets('login offers Google sign-in', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('pt'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LoginScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Continuar com Google'), findsOneWidget);

    await tester.tap(find.text('Aluno'));
    await tester.pumpAndSettle();
    expect(find.text('Usuário'), findsOneWidget);
    expect(find.text('Continuar com Google'), findsNothing);
    expect(find.text('Criar conta de responsável'), findsNothing);
  });

  testWidgets('parent dashboard lists linked children', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studentsProvider.overrideWith(
            (ref) async => [
              StudentRecord(
                id: 'student-id',
                fullName: 'João Silva',
                birthDate: DateTime(2018, 3, 5),
                username: 'joao',
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
    expect(find.textContaining('Usuário: joao'), findsOneWidget);
  });

  testWidgets('registration requires full name and email', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('pt'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SignUpScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Criar conta'));
    await tester.tap(find.text('Criar conta'));
    await tester.pumpAndSettle();

    expect(find.text('Informe seu nome completo.'), findsOneWidget);
    expect(find.text('Informe um e-mail válido.'), findsOneWidget);
  });

  testWidgets('parent passport shows progress and keeps checklist read-only', (
    WidgetTester tester,
  ) async {
    final passport = StudentPassport(
      studentId: 'student-id',
      studentName: 'João Silva',
      currentBeltNamePt: 'Amarela',
      currentBeltNameEs: 'Amarillo',
      currentBeltColor: '#FFFF00',
      cycle: PassportCycle(
        id: 'cycle-id',
        name: 'Ciclo inicial',
        startDate: DateTime(2026, 1, 1),
        endDate: null,
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
          PassportChecklistItem(
            id: 'optional',
            namePt: 'Ajudar um colega',
            nameEs: 'Ayudar a un compañero',
            descriptionPt: null,
            descriptionEs: null,
            required: false,
            isCompleted: true,
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studentPassportProvider.overrideWith((ref, studentId) async {
            return passport;
          }),
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
            body: StudentPassportView(studentId: 'student-id'),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('1 de 2 atividades obrigatórias'), findsOneWidget);
    expect(find.text('Faixa atual: Amarela'), findsOneWidget);
    expect(
      tester
          .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
          .every((tile) => tile.onChanged == null),
      isTrue,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studentPassportProvider.overrideWith((ref, studentId) async {
            return passport;
          }),
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
              studentId: 'student-id',
              allowCompletion: true,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(
      tester
          .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
          .every((tile) => tile.onChanged != null),
      isTrue,
    );
  });
}
