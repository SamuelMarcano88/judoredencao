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
  String get continueWithGoogle => 'Continuar com Google';

  @override
  String get googleSignInUnavailable =>
      'Não foi possível iniciar o login com Google.';

  @override
  String get createParentAccount => 'Criar conta de responsável';

  @override
  String get createAccount => 'Criar conta';

  @override
  String get fullName => 'Nome completo';

  @override
  String get fullNameRequired => 'Informe seu nome completo.';

  @override
  String get validEmailRequired => 'Informe um e-mail válido.';

  @override
  String get passwordMinimum => 'A senha deve ter pelo menos 8 caracteres.';

  @override
  String get confirmPassword => 'Confirmar senha';

  @override
  String get passwordsDoNotMatch => 'As senhas não coincidem.';

  @override
  String get accountCreated => 'Conta criada com sucesso!';

  @override
  String get confirmEmailHint =>
      'Verifique seu e-mail para confirmar a conta e depois entre.';

  @override
  String get parentRegistrationHint =>
      'Cadastre-se como responsável para acompanhar seus filhos.';

  @override
  String get profileNotConfigured =>
      'Perfil não configurado. Fale com o administrador da academia.';

  @override
  String get authResponseDecodeHint =>
      'O Supabase não conseguiu concluir o cadastro. Verifique a configuração SMTP e os Logs de Auth do projeto; o SMTP padrão só envia para e-mails autorizados da equipe.';

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
