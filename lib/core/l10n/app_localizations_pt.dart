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
  String get passport => 'Passaporte';

  @override
  String get cycles => 'Ciclos';

  @override
  String get currentBelt => 'Faixa atual';

  @override
  String get nextBelt => 'Próxima faixa';

  @override
  String get beltNotDefined => 'Faixa ainda não definida';

  @override
  String get currentCycle => 'Ciclo atual';

  @override
  String get noCycleAssigned => 'Nenhum ciclo foi atribuído a este aluno.';

  @override
  String get cycleProgress => 'Progresso do ciclo';

  @override
  String requiredActivitiesProgress(int completed, int total) {
    return '$completed de $total atividades obrigatórias';
  }

  @override
  String get checklist => 'Checklist';

  @override
  String get noChecklistActivities => 'Este ciclo ainda não tem atividades.';

  @override
  String get optionalActivity => 'Opcional';

  @override
  String get createCycle => 'Criar ciclo';

  @override
  String get createCycleDetails =>
      'Configure o ciclo, os alunos e as atividades.';

  @override
  String get cycleName => 'Nome do ciclo';

  @override
  String get cycleNameRequired => 'Informe o nome do ciclo.';

  @override
  String get startDate => 'Data de início';

  @override
  String get endDateOptional => 'Data de término (opcional)';

  @override
  String get clearDate => 'Limpar data';

  @override
  String get cycleDateRangeInvalid =>
      'A data final deve ser igual ou posterior à inicial.';

  @override
  String get noBeltSelected => 'Não definida';

  @override
  String get cycleParticipants => 'Alunos participantes';

  @override
  String get selectParticipantsHint => 'Selecione pelo menos um aluno.';

  @override
  String get noStudentsAvailable => 'Cadastre alunos antes de criar um ciclo.';

  @override
  String get checklistActivities => 'Atividades do checklist';

  @override
  String get addActivity => 'Adicionar atividade';

  @override
  String get activityNamePortuguese => 'Atividade em português';

  @override
  String get activityNameSpanish => 'Atividade em espanhol';

  @override
  String get activityNameRequired => 'Informe a atividade nos dois idiomas.';

  @override
  String get categoryNamePortugueseOptional =>
      'Categoria em português (opcional)';

  @override
  String get categoryNameSpanishOptional => 'Categoria em espanhol (opcional)';

  @override
  String get categoryNamesBothRequired =>
      'Informe a categoria nos dois idiomas ou deixe ambos vazios.';

  @override
  String get removeActivity => 'Remover atividade';

  @override
  String get createCycleFailed => 'Não foi possível criar o ciclo';

  @override
  String get noCycles => 'Nenhum ciclo foi criado ainda.';

  @override
  String get cycleStatusActive => 'Ativo';

  @override
  String get cycleStatusPlanned => 'Planejado';

  @override
  String get cycleStatusCompleted => 'Concluído';

  @override
  String get requiredActivity => 'Atividade obrigatória';

  @override
  String get activityUpdateFailed => 'Não foi possível atualizar a atividade';

  @override
  String get progressOverview => 'Resumo do progresso';

  @override
  String technicalRequirementsSummary(int achieved, int total) {
    return '$achieved de $total requisitos técnicos concluídos';
  }

  @override
  String get attendance => 'Presença';

  @override
  String get attendanceHistory => 'Histórico de presença';

  @override
  String get attendanceRate => 'Frequência';

  @override
  String get attendanceRateNotAvailable => 'Não disponível';

  @override
  String get attendanceRecordedClasses => 'Aulas registradas';

  @override
  String get noAttendanceRecords => 'Ainda não há registros de presença.';

  @override
  String get present => 'Presente';

  @override
  String get absent => 'Ausente';

  @override
  String get excused => 'Justificado';

  @override
  String get chooseAttendance => 'Selecionar presença';

  @override
  String get attendanceDate => 'Data da aula';

  @override
  String get saveAttendance => 'Salvar presença';

  @override
  String get attendanceSaved => 'Presença salva com sucesso.';

  @override
  String get attendanceSaveFailed => 'Não foi possível salvar a presença';

  @override
  String get attendanceIncomplete => 'Selecione a presença de cada aluno.';

  @override
  String get noStudentsInCycle => 'Não há alunos inscritos neste ciclo.';

  @override
  String get technicalProgress => 'Evolução técnica';

  @override
  String get technicalRequirements => 'Requisitos técnicos';

  @override
  String get noTechnicalRequirements =>
      'Não há requisitos técnicos configurados para esta faixa.';

  @override
  String get technicalRequirementNotReady =>
      'Defina a próxima faixa no ciclo para acompanhar os requisitos.';

  @override
  String get technicalStatusDeveloping => 'Em desenvolvimento';

  @override
  String get technicalStatusNeedsWork => 'Precisa praticar';

  @override
  String get technicalStatusAchieved => 'Conquistado';

  @override
  String get notEvaluated => 'Ainda não avaliado';

  @override
  String get evaluate => 'Avaliar';

  @override
  String get technicalEvaluation => 'Avaliação técnica';

  @override
  String get evaluationObservation => 'Observação (opcional)';

  @override
  String get saveEvaluation => 'Salvar avaliação';

  @override
  String get evaluationSaved => 'Avaliação salva com sucesso.';

  @override
  String get evaluationSaveFailed => 'Não foi possível salvar a avaliação';

  @override
  String get createTechnicalRequirement => 'Adicionar requisito';

  @override
  String get technicalRequirementNamePt => 'Requisito em português';

  @override
  String get technicalRequirementNameEs => 'Requisito em espanhol';

  @override
  String get technicalRequirementNameRequired =>
      'Informe o requisito em português e espanhol.';

  @override
  String get technicalRequirementDescriptionPt =>
      'Descrição em português (opcional)';

  @override
  String get technicalRequirementDescriptionEs =>
      'Descrição em espanhol (opcional)';

  @override
  String get selectBelt => 'Selecione uma faixa';

  @override
  String get noBeltsAvailable =>
      'Cadastre as faixas antes de adicionar requisitos técnicos.';

  @override
  String get technicalRequirementCreated => 'Requisito técnico adicionado.';

  @override
  String get technicalRequirementCreateFailed =>
      'Não foi possível adicionar o requisito técnico';

  @override
  String get studentPassportUnavailable =>
      'Não foi possível localizar o passaporte deste aluno.';

  @override
  String get invalidCredentials => 'E-mail ou senha inválidos.';

  @override
  String get unexpectedError => 'Não foi possível concluir a operação.';
}
