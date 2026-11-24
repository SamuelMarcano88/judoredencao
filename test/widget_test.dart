import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:missao_proxima_faixa/core/l10n/app_localizations.dart';
import 'package:missao_proxima_faixa/features/auth/presentation/sign_up_screen.dart';

void main() {
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
}
