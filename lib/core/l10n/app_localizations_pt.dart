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
  String get loginAsParent => 'Responsável';

  @override
  String get loginAsStudent => 'Aluno';

  @override
  String get username => 'Usuário';

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
  String get students => 'Alunos';

  @override
  String get parents => 'Responsáveis';

  @override
  String get myChildren => 'Meus filhos';

  @override
  String get addStudent => 'Cadastrar aluno';

  @override
  String get editStudent => 'Editar aluno';

  @override
  String get save => 'Salvar';

  @override
  String get createStudent => 'Criar perfil e acesso do aluno';

  @override
  String get studentDetails => 'Dados do aluno';

  @override
  String get studentAccessDetails => 'Acesso individual do aluno';

  @override
  String get studentName => 'Nome completo do aluno';

  @override
  String get studentNameRequired => 'Informe o nome completo do aluno.';

  @override
  String get birthDateOptional => 'Data de nascimento (opcional)';

  @override
  String get studentPassword => 'Senha do aluno';

  @override
  String get usernameRules =>
      '3 a 30 caracteres: letras, números, ponto, hífen ou sublinhado.';

  @override
  String get relationshipOptional => 'Parentesco (opcional)';

  @override
  String get parent => 'Responsável';

  @override
  String get selectParent => 'Selecione um responsável.';

  @override
  String get noParentsForAssignment =>
      'Cadastre primeiro uma conta de responsável.';

  @override
  String get noStudents => 'Nenhum aluno cadastrado ainda.';

  @override
  String get noParents => 'Nenhuma conta de responsável encontrada.';

  @override
  String get studentCreationFailed => 'Não foi possível cadastrar o aluno';

  @override
  String get studentUpdateFailed => 'Não foi possível atualizar o aluno';

  @override
  String get dashboardLoadError => 'Não foi possível carregar os dados';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get stageOne => 'Etapa 1: arquitetura e autenticação';

  @override
  String get invalidCredentials => 'E-mail ou senha inválidos.';

  @override
  String get unexpectedError => 'Não foi possível concluir a operação.';
}
