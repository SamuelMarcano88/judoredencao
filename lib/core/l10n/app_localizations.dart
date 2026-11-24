import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'MISSÃO PRÓXIMA FAIXA'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get login;

  /// No description provided for @loginAsParent.
  ///
  /// In pt, this message translates to:
  /// **'Responsável'**
  String get loginAsParent;

  /// No description provided for @loginAsStudent.
  ///
  /// In pt, this message translates to:
  /// **'Aluno'**
  String get loginAsStudent;

  /// No description provided for @username.
  ///
  /// In pt, this message translates to:
  /// **'Usuário'**
  String get username;

  /// No description provided for @continueWithGoogle.
  ///
  /// In pt, this message translates to:
  /// **'Continuar com Google'**
  String get continueWithGoogle;

  /// No description provided for @googleSignInUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível iniciar o login com Google.'**
  String get googleSignInUnavailable;

  /// No description provided for @createParentAccount.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta de responsável'**
  String get createParentAccount;

  /// No description provided for @createAccount.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get createAccount;

  /// No description provided for @fullName.
  ///
  /// In pt, this message translates to:
  /// **'Nome completo'**
  String get fullName;

  /// No description provided for @fullNameRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe seu nome completo.'**
  String get fullNameRequired;

  /// No description provided for @validEmailRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe um e-mail válido.'**
  String get validEmailRequired;

  /// No description provided for @passwordMinimum.
  ///
  /// In pt, this message translates to:
  /// **'A senha deve ter pelo menos 8 caracteres.'**
  String get passwordMinimum;

  /// No description provided for @confirmPassword.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar senha'**
  String get confirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In pt, this message translates to:
  /// **'As senhas não coincidem.'**
  String get passwordsDoNotMatch;

  /// No description provided for @accountCreated.
  ///
  /// In pt, this message translates to:
  /// **'Conta criada com sucesso!'**
  String get accountCreated;

  /// No description provided for @confirmEmailHint.
  ///
  /// In pt, this message translates to:
  /// **'Verifique seu e-mail para confirmar a conta e depois entre.'**
  String get confirmEmailHint;

  /// No description provided for @parentRegistrationHint.
  ///
  /// In pt, this message translates to:
  /// **'Cadastre-se como responsável para acompanhar seus filhos.'**
  String get parentRegistrationHint;

  /// No description provided for @profileNotConfigured.
  ///
  /// In pt, this message translates to:
  /// **'Perfil não configurado. Fale com o administrador da academia.'**
  String get profileNotConfigured;

  /// No description provided for @authResponseDecodeHint.
  ///
  /// In pt, this message translates to:
  /// **'O Supabase não conseguiu concluir o cadastro. Verifique a configuração SMTP e os Logs de Auth do projeto; o SMTP padrão só envia para e-mails autorizados da equipe.'**
  String get authResponseDecodeHint;

  /// No description provided for @email.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get email;

  /// No description provided for @password.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get password;

  /// No description provided for @logout.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get logout;

  /// No description provided for @configurationRequired.
  ///
  /// In pt, this message translates to:
  /// **'Configuração do Supabase necessária'**
  String get configurationRequired;

  /// No description provided for @configurationHint.
  ///
  /// In pt, this message translates to:
  /// **'Informe SUPABASE_URL e SUPABASE_ANON_KEY.'**
  String get configurationHint;

  /// No description provided for @welcome.
  ///
  /// In pt, this message translates to:
  /// **'Olá!'**
  String get welcome;

  /// No description provided for @adminDashboard.
  ///
  /// In pt, this message translates to:
  /// **'Painel administrativo'**
  String get adminDashboard;

  /// No description provided for @parentDashboard.
  ///
  /// In pt, this message translates to:
  /// **'Painel do responsável'**
  String get parentDashboard;

  /// No description provided for @studentDashboard.
  ///
  /// In pt, this message translates to:
  /// **'Painel do aluno'**
  String get studentDashboard;

  /// No description provided for @students.
  ///
  /// In pt, this message translates to:
  /// **'Alunos'**
  String get students;

  /// No description provided for @parents.
  ///
  /// In pt, this message translates to:
  /// **'Responsáveis'**
  String get parents;

  /// No description provided for @myChildren.
  ///
  /// In pt, this message translates to:
  /// **'Meus filhos'**
  String get myChildren;

  /// No description provided for @addStudent.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar aluno'**
  String get addStudent;

  /// No description provided for @editStudent.
  ///
  /// In pt, this message translates to:
  /// **'Editar aluno'**
  String get editStudent;

  /// No description provided for @save.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get save;

  /// No description provided for @createStudent.
  ///
  /// In pt, this message translates to:
  /// **'Criar perfil e acesso do aluno'**
  String get createStudent;

  /// No description provided for @studentDetails.
  ///
  /// In pt, this message translates to:
  /// **'Dados do aluno'**
  String get studentDetails;

  /// No description provided for @studentAccessDetails.
  ///
  /// In pt, this message translates to:
  /// **'Acesso individual do aluno'**
  String get studentAccessDetails;

  /// No description provided for @studentName.
  ///
  /// In pt, this message translates to:
  /// **'Nome completo do aluno'**
  String get studentName;

  /// No description provided for @studentNameRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe o nome completo do aluno.'**
  String get studentNameRequired;

  /// No description provided for @birthDateOptional.
  ///
  /// In pt, this message translates to:
  /// **'Data de nascimento (opcional)'**
  String get birthDateOptional;

  /// No description provided for @studentPassword.
  ///
  /// In pt, this message translates to:
  /// **'Senha do aluno'**
  String get studentPassword;

  /// No description provided for @usernameRules.
  ///
  /// In pt, this message translates to:
  /// **'3 a 30 caracteres: letras, números, ponto, hífen ou sublinhado.'**
  String get usernameRules;

  /// No description provided for @relationshipOptional.
  ///
  /// In pt, this message translates to:
  /// **'Parentesco (opcional)'**
  String get relationshipOptional;

  /// No description provided for @parent.
  ///
  /// In pt, this message translates to:
  /// **'Responsável'**
  String get parent;

  /// No description provided for @selectParent.
  ///
  /// In pt, this message translates to:
  /// **'Selecione um responsável.'**
  String get selectParent;

  /// No description provided for @noParentsForAssignment.
  ///
  /// In pt, this message translates to:
  /// **'Cadastre primeiro uma conta de responsável.'**
  String get noParentsForAssignment;

  /// No description provided for @noStudents.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum aluno cadastrado ainda.'**
  String get noStudents;

  /// No description provided for @noParents.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma conta de responsável encontrada.'**
  String get noParents;

  /// No description provided for @studentCreationFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível cadastrar o aluno'**
  String get studentCreationFailed;

  /// No description provided for @studentUpdateFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível atualizar o aluno'**
  String get studentUpdateFailed;

  /// No description provided for @dashboardLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os dados'**
  String get dashboardLoadError;

  /// No description provided for @retry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get retry;

  /// No description provided for @passport.
  ///
  /// In pt, this message translates to:
  /// **'Passaporte'**
  String get passport;

  /// No description provided for @cycles.
  ///
  /// In pt, this message translates to:
  /// **'Ciclos'**
  String get cycles;

  /// No description provided for @currentBelt.
  ///
  /// In pt, this message translates to:
  /// **'Faixa atual'**
  String get currentBelt;

  /// No description provided for @nextBelt.
  ///
  /// In pt, this message translates to:
  /// **'Próxima faixa'**
  String get nextBelt;

  /// No description provided for @beltNotDefined.
  ///
  /// In pt, this message translates to:
  /// **'Faixa ainda não definida'**
  String get beltNotDefined;

  /// No description provided for @currentCycle.
  ///
  /// In pt, this message translates to:
  /// **'Ciclo atual'**
  String get currentCycle;

  /// No description provided for @noCycleAssigned.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum ciclo foi atribuído a este aluno.'**
  String get noCycleAssigned;

  /// No description provided for @cycleProgress.
  ///
  /// In pt, this message translates to:
  /// **'Progresso do ciclo'**
  String get cycleProgress;

  /// No description provided for @requiredActivitiesProgress.
  ///
  /// In pt, this message translates to:
  /// **'{completed} de {total} atividades obrigatórias'**
  String requiredActivitiesProgress(int completed, int total);

  /// No description provided for @checklist.
  ///
  /// In pt, this message translates to:
  /// **'Checklist'**
  String get checklist;

  /// No description provided for @noChecklistActivities.
  ///
  /// In pt, this message translates to:
  /// **'Este ciclo ainda não tem atividades.'**
  String get noChecklistActivities;

  /// No description provided for @optionalActivity.
  ///
  /// In pt, this message translates to:
  /// **'Opcional'**
  String get optionalActivity;

  /// No description provided for @createCycle.
  ///
  /// In pt, this message translates to:
  /// **'Criar ciclo'**
  String get createCycle;

  /// No description provided for @createCycleDetails.
  ///
  /// In pt, this message translates to:
  /// **'Configure o ciclo, os alunos e as atividades.'**
  String get createCycleDetails;

  /// No description provided for @cycleName.
  ///
  /// In pt, this message translates to:
  /// **'Nome do ciclo'**
  String get cycleName;

  /// No description provided for @cycleNameRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe o nome do ciclo.'**
  String get cycleNameRequired;

  /// No description provided for @startDate.
  ///
  /// In pt, this message translates to:
  /// **'Data de início'**
  String get startDate;

  /// No description provided for @endDateOptional.
  ///
  /// In pt, this message translates to:
  /// **'Data de término (opcional)'**
  String get endDateOptional;

  /// No description provided for @clearDate.
  ///
  /// In pt, this message translates to:
  /// **'Limpar data'**
  String get clearDate;

  /// No description provided for @cycleDateRangeInvalid.
  ///
  /// In pt, this message translates to:
  /// **'A data final deve ser igual ou posterior à inicial.'**
  String get cycleDateRangeInvalid;

  /// No description provided for @noBeltSelected.
  ///
  /// In pt, this message translates to:
  /// **'Não definida'**
  String get noBeltSelected;

  /// No description provided for @cycleParticipants.
  ///
  /// In pt, this message translates to:
  /// **'Alunos participantes'**
  String get cycleParticipants;

  /// No description provided for @selectParticipantsHint.
  ///
  /// In pt, this message translates to:
  /// **'Selecione pelo menos um aluno.'**
  String get selectParticipantsHint;

  /// No description provided for @noStudentsAvailable.
  ///
  /// In pt, this message translates to:
  /// **'Cadastre alunos antes de criar um ciclo.'**
  String get noStudentsAvailable;

  /// No description provided for @checklistActivities.
  ///
  /// In pt, this message translates to:
  /// **'Atividades do checklist'**
  String get checklistActivities;

  /// No description provided for @addActivity.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar atividade'**
  String get addActivity;

  /// No description provided for @activityNamePortuguese.
  ///
  /// In pt, this message translates to:
  /// **'Atividade em português'**
  String get activityNamePortuguese;

  /// No description provided for @activityNameSpanish.
  ///
  /// In pt, this message translates to:
  /// **'Atividade em espanhol'**
  String get activityNameSpanish;

  /// No description provided for @activityNameRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe a atividade nos dois idiomas.'**
  String get activityNameRequired;

  /// No description provided for @categoryNamePortugueseOptional.
  ///
  /// In pt, this message translates to:
  /// **'Categoria em português (opcional)'**
  String get categoryNamePortugueseOptional;

  /// No description provided for @categoryNameSpanishOptional.
  ///
  /// In pt, this message translates to:
  /// **'Categoria em espanhol (opcional)'**
  String get categoryNameSpanishOptional;

  /// No description provided for @categoryNamesBothRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe a categoria nos dois idiomas ou deixe ambos vazios.'**
  String get categoryNamesBothRequired;

  /// No description provided for @removeActivity.
  ///
  /// In pt, this message translates to:
  /// **'Remover atividade'**
  String get removeActivity;

  /// No description provided for @createCycleFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível criar o ciclo'**
  String get createCycleFailed;

  /// No description provided for @noCycles.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum ciclo foi criado ainda.'**
  String get noCycles;

  /// No description provided for @cycleStatusActive.
  ///
  /// In pt, this message translates to:
  /// **'Ativo'**
  String get cycleStatusActive;

  /// No description provided for @cycleStatusPlanned.
  ///
  /// In pt, this message translates to:
  /// **'Planejado'**
  String get cycleStatusPlanned;

  /// No description provided for @cycleStatusCompleted.
  ///
  /// In pt, this message translates to:
  /// **'Concluído'**
  String get cycleStatusCompleted;

  /// No description provided for @requiredActivity.
  ///
  /// In pt, this message translates to:
  /// **'Atividade obrigatória'**
  String get requiredActivity;

  /// No description provided for @activityUpdateFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível atualizar a atividade'**
  String get activityUpdateFailed;

  /// No description provided for @attendance.
  ///
  /// In pt, this message translates to:
  /// **'Presença'**
  String get attendance;

  /// No description provided for @attendanceHistory.
  ///
  /// In pt, this message translates to:
  /// **'Histórico de presença'**
  String get attendanceHistory;

  /// No description provided for @attendanceRate.
  ///
  /// In pt, this message translates to:
  /// **'Frequência'**
  String get attendanceRate;

  /// No description provided for @attendanceRateNotAvailable.
  ///
  /// In pt, this message translates to:
  /// **'Não disponível'**
  String get attendanceRateNotAvailable;

  /// No description provided for @attendanceRecordedClasses.
  ///
  /// In pt, this message translates to:
  /// **'Aulas registradas'**
  String get attendanceRecordedClasses;

  /// No description provided for @noAttendanceRecords.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não há registros de presença.'**
  String get noAttendanceRecords;

  /// No description provided for @present.
  ///
  /// In pt, this message translates to:
  /// **'Presente'**
  String get present;

  /// No description provided for @absent.
  ///
  /// In pt, this message translates to:
  /// **'Ausente'**
  String get absent;

  /// No description provided for @excused.
  ///
  /// In pt, this message translates to:
  /// **'Justificado'**
  String get excused;

  /// No description provided for @chooseAttendance.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar presença'**
  String get chooseAttendance;

  /// No description provided for @attendanceDate.
  ///
  /// In pt, this message translates to:
  /// **'Data da aula'**
  String get attendanceDate;

  /// No description provided for @saveAttendance.
  ///
  /// In pt, this message translates to:
  /// **'Salvar presença'**
  String get saveAttendance;

  /// No description provided for @attendanceSaved.
  ///
  /// In pt, this message translates to:
  /// **'Presença salva com sucesso.'**
  String get attendanceSaved;

  /// No description provided for @attendanceSaveFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar a presença'**
  String get attendanceSaveFailed;

  /// No description provided for @attendanceIncomplete.
  ///
  /// In pt, this message translates to:
  /// **'Selecione a presença de cada aluno.'**
  String get attendanceIncomplete;

  /// No description provided for @noStudentsInCycle.
  ///
  /// In pt, this message translates to:
  /// **'Não há alunos inscritos neste ciclo.'**
  String get noStudentsInCycle;

  /// No description provided for @technicalProgress.
  ///
  /// In pt, this message translates to:
  /// **'Evolução técnica'**
  String get technicalProgress;

  /// No description provided for @technicalRequirements.
  ///
  /// In pt, this message translates to:
  /// **'Requisitos técnicos'**
  String get technicalRequirements;

  /// No description provided for @noTechnicalRequirements.
  ///
  /// In pt, this message translates to:
  /// **'Não há requisitos técnicos configurados para esta faixa.'**
  String get noTechnicalRequirements;

  /// No description provided for @technicalRequirementNotReady.
  ///
  /// In pt, this message translates to:
  /// **'Defina a próxima faixa no ciclo para acompanhar os requisitos.'**
  String get technicalRequirementNotReady;

  /// No description provided for @technicalStatusDeveloping.
  ///
  /// In pt, this message translates to:
  /// **'Em desenvolvimento'**
  String get technicalStatusDeveloping;

  /// No description provided for @technicalStatusNeedsWork.
  ///
  /// In pt, this message translates to:
  /// **'Precisa praticar'**
  String get technicalStatusNeedsWork;

  /// No description provided for @technicalStatusAchieved.
  ///
  /// In pt, this message translates to:
  /// **'Conquistado'**
  String get technicalStatusAchieved;

  /// No description provided for @notEvaluated.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não avaliado'**
  String get notEvaluated;

  /// No description provided for @evaluate.
  ///
  /// In pt, this message translates to:
  /// **'Avaliar'**
  String get evaluate;

  /// No description provided for @technicalEvaluation.
  ///
  /// In pt, this message translates to:
  /// **'Avaliação técnica'**
  String get technicalEvaluation;

  /// No description provided for @evaluationObservation.
  ///
  /// In pt, this message translates to:
  /// **'Observação (opcional)'**
  String get evaluationObservation;

  /// No description provided for @saveEvaluation.
  ///
  /// In pt, this message translates to:
  /// **'Salvar avaliação'**
  String get saveEvaluation;

  /// No description provided for @evaluationSaved.
  ///
  /// In pt, this message translates to:
  /// **'Avaliação salva com sucesso.'**
  String get evaluationSaved;

  /// No description provided for @evaluationSaveFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar a avaliação'**
  String get evaluationSaveFailed;

  /// No description provided for @createTechnicalRequirement.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar requisito'**
  String get createTechnicalRequirement;

  /// No description provided for @technicalRequirementNamePt.
  ///
  /// In pt, this message translates to:
  /// **'Requisito em português'**
  String get technicalRequirementNamePt;

  /// No description provided for @technicalRequirementNameEs.
  ///
  /// In pt, this message translates to:
  /// **'Requisito em espanhol'**
  String get technicalRequirementNameEs;

  /// No description provided for @technicalRequirementNameRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe o requisito em português e espanhol.'**
  String get technicalRequirementNameRequired;

  /// No description provided for @technicalRequirementDescriptionPt.
  ///
  /// In pt, this message translates to:
  /// **'Descrição em português (opcional)'**
  String get technicalRequirementDescriptionPt;

  /// No description provided for @technicalRequirementDescriptionEs.
  ///
  /// In pt, this message translates to:
  /// **'Descrição em espanhol (opcional)'**
  String get technicalRequirementDescriptionEs;

  /// No description provided for @selectBelt.
  ///
  /// In pt, this message translates to:
  /// **'Selecione uma faixa'**
  String get selectBelt;

  /// No description provided for @noBeltsAvailable.
  ///
  /// In pt, this message translates to:
  /// **'Cadastre as faixas antes de adicionar requisitos técnicos.'**
  String get noBeltsAvailable;

  /// No description provided for @technicalRequirementCreated.
  ///
  /// In pt, this message translates to:
  /// **'Requisito técnico adicionado.'**
  String get technicalRequirementCreated;

  /// No description provided for @technicalRequirementCreateFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível adicionar o requisito técnico'**
  String get technicalRequirementCreateFailed;

  /// No description provided for @studentPassportUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível localizar o passaporte deste aluno.'**
  String get studentPassportUnavailable;

  /// No description provided for @invalidCredentials.
  ///
  /// In pt, this message translates to:
  /// **'E-mail ou senha inválidos.'**
  String get invalidCredentials;

  /// No description provided for @unexpectedError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível concluir a operação.'**
  String get unexpectedError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
