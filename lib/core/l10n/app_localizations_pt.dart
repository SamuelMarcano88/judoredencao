// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'MISSÃO PRÓXIMA FAIXA';

  @override
  String get login => 'Entrar';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Senha';

  @override
  String get logout => 'Sair';

  @override
  String get configurationRequired => 'Configuração do Supabase necessária';

  @override
  String get configurationHint => 'Informe SUPABASE_URL e SUPABASE_ANON_KEY.';

  @override
  String get welcome => 'Olá!';

  @override
  String get adminDashboard => 'Painel administrativo';

  @override
  String get parentDashboard => 'Painel do responsável';

  @override
  String get studentDashboard => 'Painel do aluno';

  @override
  String get stageOne => 'Etapa 1: arquitetura e autenticação';

  @override
  String get invalidCredentials => 'E-mail ou senha inválidos.';

  @override
  String get unexpectedError => 'Não foi possível concluir a operação.';
}
